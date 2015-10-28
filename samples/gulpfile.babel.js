"use strict";

import gulp from 'gulp';
import autoprefixer from 'gulp-autoprefixer';
import browserify from 'browserify'; // Bundles JS
import changed from 'gulp-changed';
import concat from 'gulp-concat'; // Concatenates files
import connect from 'gulp-connect'; // Runs a local dev server
import del from 'del';
import gutil from 'gulp-util';
import imageoptim from 'gulp-imageoptim';
import less from 'gulp-less';
import lint from 'gulp-eslint'; // Lint JS files, including JSX
import minify from 'gulp-minify-css'; // Minifies css files
import open from 'gulp-open'; // Open a URL in a web browser
import sass from 'gulp-sass';
import source from 'vinyl-source-stream'; // Use conventional text streams with Gulp
import streamify from 'gulp-streamify'; // Uglify stream bug
import svgmin from 'gulp-svgmin'; // Shrink those svgs
import uglify from 'gulp-uglify'; // Minifies js files
import spritesmith from 'gulp.spritesmith';
import csslint from 'gulp-csslint';

const config = {
	port: 9005,
	devBaseUrl: 'http://localhost',
	paths: {
		html: './*{.html,.php}',
		images: './images/**/*',
		bitmaps: './images/**/*{.jpg,.png,.gif}',
		svgs: './images/**/*.svg',
		js: [
			'./js/loadCSS.js',
			'./js/ga.js',
			'./js/jquery.bxslider.js',
			'./js/twitterFetcher_v10_min.js',
			'./js/functions.js',
		],
		css: './css/**/*.scss',
		staticFiles: [
			'./apple-touch-icon.png',
			'./favicon.ico',
			'./Fonts/**/*',
			'./screenshot.png',
		],
		dist: './dist-theme'
	}
}

gulp.task('optimize:bitmaps', () => {
	gulp.src(config.paths.bitmaps)
		.pipe(changed(config.paths.bitmaps))
		.pipe(imageoptim.optimize())
		.pipe(gulp.dest('images'));
});

gulp.task('optimize:svgs', () => {
	gulp.src(config.paths.svgs)
		.pipe(changed(config.paths.svgs))
		.pipe(svgmin())
		.pipe(gulp.dest('images'));
});

gulp.task('optimize', ['optimize:bitmaps', 'optimize:svgs'], () => {
	gulp.src(config.paths.images)
		.pipe(gulp.dest(config.paths.dist + '/images'));
});

gulp.task('spritesmith', () => {
	const spriteData = gulp.src('images/sprite/*.png').pipe(spritesmith({
		algorithm: 'top-down',
		algorithmOpts: {
     		'sort': false
		},
		cssName: 'sprite.css',
		imgName: 'sprite.png'
	}));
	return spriteData.pipe(gulp.dest('images'));
});

gulp.task('clean', () => {
	return del(config.paths.dist + '/**/*');
});

//Start a local development server
gulp.task('connect', ['clean'], () => {
	connect.server({
		root: [config.paths.dist],
		port: config.port,
		base: config.devBaseUrl,
		livereload: true
	});
});

gulp.task('open', ['connect'], () => {
	gulp.src(config.paths.dist + '/index.html')
		.pipe(open({ uri: config.devBaseUrl + ':' + config.port + '/'}));
});

gulp.task('html', () => {
	gulp.src(config.paths.html)
		.pipe(gulp.dest(config.paths.dist));
		// .pipe(connect.reload());

	//publish static content
	gulp.src(config.paths.staticFiles, {
            base: '.'
        })
		.pipe(gulp.dest(config.paths.dist));
});

gulp.task('images', () => {
	gulp.src([
			config.paths.images
		])
		.pipe(gulp.dest(config.paths.dist + '/images'))
		// .pipe(connect.reload());
});

gulp.task('js', () => {
	gulp.src(config.paths.js)
		.pipe(concat('bundle.js'))
		//only uglify if gulp is ran with '--type production'
		.pipe(gutil.env.type === 'production' ? streamify(uglify()) : gutil.noop()) 
		.pipe(gulp.dest(config.paths.dist + '/js'))
		// .pipe(connect.reload());
});

gulp.task('css', () => {
	gulp.src(config.paths.css)
		.pipe(gutil.env.type === 'production' ? sass({outputStyle: 'compressed'}).on('error', sass.logError) : sass({outputStyle: 'expanded'}).on('error', sass.logError))
		.pipe(concat('style.css'))
		.pipe(autoprefixer({
			browsers: ['last 2 versions']
		}))
		.pipe(csslint({
			'adjoining-classes': false,
			'compatible-vendor-prefixes': false,
			'known-properties': false,
			'box-model': false,
			'box-sizing': false,
			'universal-selector': false,
			'bulletproof-font-face': false
		}))
    	.pipe(csslint.reporter())
		//only minify if gulp is ran with '--type production'
		.pipe(gutil.env.type === 'production' ? minify() : gutil.noop())
		.pipe(gulp.dest(config.paths.dist))
		// .pipe(connect.reload());
});

gulp.task('lint', () => {
	return gulp.src(config.paths.js)
		.pipe(lint({config: 'eslint.config.json'}))
		.pipe(lint.format());
});

gulp.task('watch', () => {
	gulp.watch(config.paths.html, ['html']);
	gulp.watch(config.paths.js, ['js', 'lint']);
	gulp.watch(config.paths.css, ['css']);
});

gulp.task('default', ['html', 'images', 'js', 'css', 'lint', 'watch']);