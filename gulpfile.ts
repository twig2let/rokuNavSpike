import { series } from "gulp";
const concat = require('gulp-concat');
const gulp = require('gulp');
const path = require('path');
const del = require('del');
const header = require('gulp-header');
const pkg = require('./package.json');
const distDir = 'dist';
const outDir = 'out';
const distFile = `rooibosDist.brs`;
const fullDistPath = path.join(distDir, distFile);
const fs = require('fs');
const rmLines = require('gulp-rm-lines');
const gulpCopy = require('gulp-copy');
const rokuDeploy = require('roku-deploy');
const cp = require('child_process');

const args = {
  host: process.env.ROKU_HOST || '192.168.16.3',
  username: process.env.ROKU_USER || 'rokudev',
  password: process.env.ROKU_PASSWORD || 'aaaa',
  rootDir: './',
  files: ['src/**/*'],
  outDir: './out',
  retainStagingFolder: true
};


export function clean() {
  const distPath = path.join(distDir, '**');
  console.log('Doing a clean at ' + distPath);
  return del([distPath, outDir], { force: true });
}

function createDirectories() {
  return gulp.src('*.*', { read: false })
    .pipe(gulp.dest(distDir))
    .pipe(gulp.dest(outDir));
}

/**
 * This target is used for CI
 */
export function prepareFrameworkTests(cb) {
  rokuDeploy.prepublishToStaging(args);
  let task = cp.exec('rooibosC -t out/.roku-deploy-staging/source/tests -r out/.roku-deploy-staging');
  task.stdout.pipe(process.stdout)
  return task;
}

export async function deployFrameworkTests(cb) {
  await rokuDeploy.publish(args);
}

export async function zipFrameworkTests(cb) {
  await rokuDeploy.zipPackage(args);
}

export async function prepare(cb) {
  await rokuDeploy.prepublishToStaging(args);
}

export async function zip(cb) {
  await rokuDeploy.zipPackage(args);
}

export async function deploy(cb) {
  await rokuDeploy.publish(args);
}

export function doc(cb) {
  let task = cp.exec('./node_modules/.bin/jsdoc -c jsdoc.json -t node_modules/minami -d docs');
  return task;
}

exports.build = series(clean, createDirectories);
exports.runFrameworkTests = series(exports.build, prepareFrameworkTests, zipFrameworkTests, deployFrameworkTests)
exports.prePublishFrameworkTests = series(exports.build, prepareFrameworkTests)
exports.prePublish = series(exports.build, prepare)
exports.dist = series(exports.build, doc);