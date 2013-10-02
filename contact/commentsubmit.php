<?php

// commentsubmit.php -- Receive comments and e-mail them to someone
// Copyright (C) 2011 Matt Palmer <mpalmer@hezmatt.org>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3, as
//  published by the Free Software Foundation.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, see <http://www.gnu.org/licences/>


// Format of the date you want to use in your comments.  See
// http://php.net/manual/en/function.date.php for the insane details of this
// format.
$DATE_FORMAT = "Y-m-d H:i";

// Where the comment e-mails should be sent to.  This will also be used as
// the From: address.  Whilst you could, in theory, change this to take the
// address out of the form, it's *incredibly* highly recommended you don't,
// because that turns you into an open relay, and that's not cool.
$EMAIL_ADDRESS = "jwmcglone@gmail.com";

// The subject of all blog comment e-mails.  If you're running lots of these,
// you might want to customise it, or if you were running a generic comment
// handler you could take it out of the form, but really, who cares what your
// comment e-mails are titled, as long as you can recognise it?
$SUBJECT = "jmcglone.com comment received";

// The contents of the following file (relative to this PHP file) will be
// displayed after the comment is received.  Customise it to your heart's
// content.
$COMMENT_RECEIVED = "comment_received.html";

/****************************************************************************
 * HERE BE CODE
 ****************************************************************************/

$post_id = $_POST["post_id"];
unset($_POST["post_id"]);
$msg = "post_id: $post_id\n";
$msg .= "date: " . date($DATE_FORMAT) . "\n";

foreach ($_POST as $key => $value) {
	if (strstr($value, "\n") != "") {
		// Value has newlines... need to indent them so the YAML
		// looks right
		$value = str_replace("\n", "\n  ", $value);
	}
	// It's easier just to single-quote everything than to try and work
	// out what might need quoting
	$value = "'" . str_replace("'", "''", $value) . "'";
	$msg .= "$key: $value\n";
}

if (mail($EMAIL_ADDRESS, $SUBJECT, $msg, "From: $EMAIL_ADDRESS"))
{
	include $COMMENT_RECEIVED;
}
else
{
	echo "There was a problem sending the comment. Please contact the site's owner.";
}
