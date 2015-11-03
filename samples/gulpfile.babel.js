"use strict";

import gulp from 'gulp';
import autoprefixer from 'gulp-autoprefixer';
import browserify from 'browserify'; // Bundles JS
import changed from 'gulp-changed';
import concat from 'gulp-concat'; // Concatenates files
import connect from 'gulp-connect'; // Runs a local dev server
import del from 'del';
import ftp from 'vinyl-ftp';
import gutil from 'gulp-util';
import imageoptim from 'gulp-imageoptim';
import jshint from 'gulp-jshint';
import less from 'gulp-less';
import lint from 'gulp-eslint'; // Lint JS files, including JSX
import minify from 'gulp-minify-css'; // Minifies css files
import open from 'gulp-open'; // Open a URL in a web browser
import sass from 'gulp-sass';
import source from 'vinyl-source-stream'; // Use conventional text streams with Gulp
import spritesmith from 'gulp.spritesmith';
import streamify from 'gulp-streamify'; // Uglify stream bug
import svgmin from 'gulp-svgmin'; // Shrink those svgs
import uglify from 'gulp-uglify'; // Minifies js files
import webp from 'gulp-webp';

const config = {
	port: 9005,
	devBaseUrl: 'http://localhost',
	paths: {
		html: './*{.html,.php}',
		images: './images/**/*',
		bitmaps: './images/**/*{.jpg,.png,.gif,.webp}',
		svgs: './images/**/*.svg',
		js: './js/*.js',
		css: './css/**/*.scss',
		staticFiles: [
			'./js/vendor/*',
			'./apple-touch-icon.png',
			'./favicon.ico',
			'./Fonts/**/*',
			'./screenshot.png',
		],
		dist: './ampersandrew-ss-theme'
	}
}

gulp.task('deploy', ['default'], () => {

    const conn = ftp.create({
        host:     'ampersandrew.com',
        user:     'Joel@ampersandrew.com',
        password: 'Ppsalms143',
        parallel: 10,
        log:      gutil.log
    });

    const globs = [
        config.paths.dist + '/**'
    ];

    return gulp.src( globs, { base: '.', buffer: false } )
        .pipe( conn.newer( '/public_html/wp-content/themes' ) ) // only upload newer files
        .pipe( conn.dest( '/public_html/wp-content/themes' ) );
});

gulp.task('optimize:images', () => {
	gulp.src([
		config.paths.bitmaps,
		'!./images/*.webp'
		])
		.pipe(changed(config.paths.bitmaps))
		.pipe(imageoptim.optimize())
		.pipe(gulp.dest('images'));

	gulp.src(config.paths.svgs)
		.pipe(changed(config.paths.svgs))
		.pipe(svgmin())
		.pipe(gulp.dest('images'));

	return gulp.src([
		config.paths.bitmaps,
		'!./images/l-ampersandrew-inline-animated.png'
		])
		.pipe(webp({quality:100}))
		.pipe(gulp.dest('images'));
});

gulp.task('optimize', ['optimize:images'], () => {
	gulp.src(config.paths.images)
		.pipe(gulp.dest(config.paths.dist + '/images'));
});

gulp.task('spritesmith', () => {
	const spriteData = gulp.src('images/l-ampersandrew-inline-animated/*.png').pipe(spritesmith({
		algorithm: 'top-down',
		algorithmOpts: {
     		'sort': false
		},
		cssName: 'l-ampersandrew-inline-animated.css',
		imgName: 'l-ampersandrew-inline-animated.png'
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
	gulp.src(config.paths.images)
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
		//only minify if gulp is ran with '--type production'
		.pipe(gutil.env.type === 'production' ? minify() : gutil.noop())
		.pipe(gulp.dest(config.paths.dist))
		// .pipe(connect.reload());
});

gulp.task('lint', () => {
	return gulp.src([
		config.paths.js,
		'!./js/twitterFetcher_v10_min.js',
		'!./js/jquery.bxslider.js'
		])
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
            
});

gulp.task('watch', () => {
	gulp.watch(config.paths.html, ['html']);
	gulp.watch(config.paths.js, ['js', 'lint']);
	gulp.watch(config.paths.css, ['css']);
});

gulp.task('default', ['html', 'images', 'js', 'css', 'lint', 'watch']);