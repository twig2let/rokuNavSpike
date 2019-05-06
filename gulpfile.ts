import { series } from "gulp";
import { BurpConfig, BurpProcessor } from "burp-brightscript";
import { RooibosProcessor } from "rooibos-preprocessor";

const gulp = require('gulp');
const path = require('path');
const gulpClean = require('gulp-clean');
const pkg = require('./package.json');
const outDir = './build';
const rokuDeploy = require('roku-deploy');
const cp = require('child_process');

let args = {
  host: process.env.ROKU_HOST || '192.168.16.3',
  username: process.env.ROKU_USER || 'rokudev',
  password: process.env.ROKU_PASSWORD || 'aaaa',
  rootDir: './',
  // annoying bug stops these working right
  // files: [
  //   'src/**/*',
  //   '!src/components/Tests/**/*',
  //   '!src/source/tests/**/*'
  // ],
  files: ['src/**/*'],
  outDir: './build',
  retainStagingFolder: true
};

function setEnvTest(args) {
  args.files = ['src/**/*'];
}

export function clean() {
  console.log('Doing a clean at ' + outDir);
  return gulp.src(outDir, { allowEmpty:true }).pipe(gulpClean({ force: true }));
}

export function createDirectories() {
  return gulp.src('*.*', { read: false })
    .pipe(gulp.dest(outDir));
}

/**
 * This target is used for CI
 */
export async function prepareTests(cb) {
  setEnvTest(args);
  console.log(args)
  await rokuDeploy.prepublishToStaging(args);
  let processor = new RooibosProcessor('build/.roku-deploy-staging/source/tests', 'build/.roku-deploy-staging', 'build/.roku-deploy-staging/source/tests');
  processor.processFiles();

  cb();
}

export async function deployTests(cb) {
  setEnvTest(args);
  await rokuDeploy.publish(args);
}

export async function zipTests(cb) {
  setEnvTest(args);
  await rokuDeploy.zipPackage(args);
}

export async function prepare(cb) {
  console.log(args);
  await rokuDeploy.prepublishToStaging(args);
  //annoying issue makes me delete these folders, coz I can't just filter them
  //:/
  gulp.src("build/.roku-deploy-staging/components/Tests", { allowEmpty:true }).pipe(gulpClean({ force: true }));
  gulp.src("build/.roku-deploy-staging/source/tests", { allowEmpty:true }).pipe(gulpClean({ force: true }));
  
}

export async function zip(cb) {
  await rokuDeploy.zipPackage(args);
}

export function addDevLogs(cb) {
  let config: BurpConfig = {
    "sourcePath": "build/.roku-deploy-staging",
    // "sourcePath": "build/wtf",
    "globPattern": "**/*.brs",
    "replacements": [
      {
        "regex": "(^.*(logInfo|logError|logVerbose|logDebug)\\((\\s*\"))",
        "replacement": "$1#FullPath# "
      },
      {
        "regex": "(^.*(logMethod)\\((\\s*\"))",
        "replacement": "$1#FullPath# "
      }
    ]
  }
  const processor = new BurpProcessor(config);
  processor.processFiles();
  cb();
}

export async function deploy(cb) {
  await rokuDeploy.publish(args);
}

export function doc(cb) {
  let task = cp.exec('./node_modules/.bin/jsdoc -c jsdoc.json -t node_modules/minami -d docs');
  return task;
}

exports.build = series(clean, createDirectories);
exports.prePublishTests =series(exports.build, prepareTests, addDevLogs)
exports.runTests = series(exports.prePublishTests, zipTests, deployTests)
exports.prePublish = series(exports.build, prepare, addDevLogs)
exports.dist = series(exports.build, doc);