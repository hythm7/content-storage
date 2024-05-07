'use strict'

const path = require('path');
const autoprefixer = require('autoprefixer')
const miniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
	mode: 'development',
	entry: {
		'main':             './frontend/js/main.js',
		'distribution-add': './frontend/js/distribution-add.js'
	},
	output: {
		filename: '[name].bundle.js',
		path: path.resolve(__dirname, 'static'),
		clean: true
	},
	plugins: [
		new miniCssExtractPlugin()
	],
	module: {
		rules: [
			{
				test: /\.(scss)$/,
				use: [
					{
						// Extracts CSS for each JS file that includes CSS
						loader: miniCssExtractPlugin.loader
					},
					{
						// Interprets `@import` and `url()` like `import/require()` and will resolve them
						loader: 'css-loader'
					},
					{
						// Loader for webpack to process CSS with PostCSS
						loader: 'postcss-loader',
						options: {
							postcssOptions: {
								plugins: [
									autoprefixer
								]
							}
						}
					},
					{
						// Loads a SASS/SCSS file and compiles it to CSS
						loader: 'sass-loader'
					}
					
				]
			},
			{
				test: /\.woff2?$/,
				type: "asset/inline",
			}
		]
	}
};
