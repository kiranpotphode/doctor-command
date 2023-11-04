<?php

namespace WP_CLI\Doctor\Check;

use FilesystemIterator;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use WP_CLI;

/**
 * Detects any use of the `wp_cache_flush()` function.
 */
class Cache_Flush extends File_Contents {

	public function run() {
		// Path to wp-content directory.
		$wp_content_dir = defined( 'WP_CONTENT_DIR' ) ? WP_CONTENT_DIR : ABSPATH . 'wp-content';
		$directory      = new RecursiveDirectoryIterator( $wp_content_dir, FilesystemIterator::SKIP_DOTS );
		$iterator       = new RecursiveIteratorIterator( $directory, RecursiveIteratorIterator::CHILD_FIRST );

		// Regex to match.
		$this->regex = 'wp_cache_flush\(\)';

		foreach ( $iterator as $file ) {
			$this->check_file( $file );
		}

		if ( empty( $this->_matches ) ) {
			$this->set_status( 'success' );
			$this->set_message( 'Use of wp_cache_flush() not found.' );
			return;
		}

		$this->set_status( 'warning' );
		$this->set_message( 'Use of wp_cache_flush() detected.' );
	}
}
