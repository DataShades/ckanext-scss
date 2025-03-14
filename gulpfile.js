const { src, dest, watch } = require("gulp");
const if_ = require("gulp-if");
const sourcemaps = require("gulp-sourcemaps");
const sass = require('gulp-sass')(require('sass'));
const touch = require("gulp-touch-fd");
const cleanCSS = require("gulp-clean-css");

const isDev = !!process.env.DEBUG;

const build = () =>
    src("ckanext/scss/theme/main.scss")
        .pipe(if_(isDev, sourcemaps.init()))
        .pipe(sass())
        .pipe(!isDev ? cleanCSS({
            compatibility: '*', // (default) - Internet Explorer 10+ compatibility mode
            level: 2 // Optimization levels. The level option can be either 0, 1 (default), or 2, e.g.
        }) : sourcemaps.write())
        .pipe(dest("ckanext/scss/assets/css"))
        .pipe(touch());

const watchSource = () =>
    watch(
        "ckanext/scss/theme/**/*.scss",
        { ignoreInitial: false },
        build
    );
exports.watch = watchSource;
exports.build = build;
