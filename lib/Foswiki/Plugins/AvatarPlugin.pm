package Foswiki::Plugins::AvatarPlugin;

use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version
our $VERSION           = '$Rev$';
our $RELEASE           = '1.0.0';
our $SHORTDESCRIPTION  = 'Embed Avatars into Foswiki topics';
our $NO_PREFS_IN_TOPIC = 1;

=pod

---++ Future development
   2 gravatar profile popups
   4 context aware size options (configurable default and size) - or perhaps replace plugin magic with a =AVATAR= for more control
   5 could it be possible to over-ride the remote server with a user topic setting? allowing local foswiki customisations

=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {

        return 0;
    }
    Foswiki::Func::registerTagHandler( 'AVATAR', \&AVATAR );

    # Plugin correctly initialized
    return 1;
}

sub AVATAR {
    my ( $session, $params, $topic, $web, $topicObject ) = @_;

    my $size = $params->{size} || 20;

    my $linkText = '';
    if ( not defined( $Foswiki::cfg{AvatarPlugin}{UsePersonalInfoAddOn} )
        or ( not $Foswiki::cfg{AvatarPlugin}{UsePersonalInfoAddOn} ) )
    {
        my @emails = Foswiki::Func::wikinameToEmails( $params->{_DEFAULT} );

        #TODO: consider the other emails later..
        my $email = $emails[0] || $topic;
        use URI::Escape qw(uri_escape);
        use Digest::MD5 qw(md5_hex);
        my $default = $params->{default} || "mm";

        #TODO: tmpl?
        my $host = $Foswiki::cfg{Plugins}{AvatarPlugin}{ServerBaseUrl}
          || $Foswiki::cfg{AvatarPlugin}{AvatarServerBaseUrl}    # legacy
          || 'http://cdn.libravatar.org/avatar/';
        my $grav_url =
            $host
          . md5_hex( lc $email ) . "?d="
          . uri_escape($default) . "&s="
          . $size;

        $linkText = "<img src=\"$grav_url\" />" . $linkText;
    }
    else {

        #TODO: check access permission
        my ( $meta, $text ) =
          Foswiki::Func::readTopic( $Foswiki::cfg{UsersWebName},
            $params->{_DEFAULT} );

        my $picture = $meta->get( 'FIELD', 'Picture' );

        #TODO: all this needs to be in a tmpl, so it can be skinned.

#$linkText = "<img height=\"".$size."px\" src=\"".Foswiki::Func::getPubUrlPath().'/'.$Foswiki::cfg{UsersWebName}.'/'.$params->{_DEFAULT}.'/'.$picture->{value}."\" />".$linkText;

        #pub/System/PersonalInfoAddOn/silhouette.gif
        my $iweb   = $Foswiki::cfg{SystemWebName};
        my $itopic = 'PersonalInfoAddOn';
        my $image  = 'silhouette.gif';
        if ( defined($picture) and defined( $picture->{value} ) ) {
            $iweb   = $Foswiki::cfg{UsersWebName};
            $itopic = $params->{_DEFAULT};
            $image  = $picture->{value};
        }

        #ask ImagePlugin for an image the right size..
        require Foswiki::Plugins::ImagePlugin;
        $linkText = Foswiki::Plugins::ImagePlugin::handleIMAGE(
            $session,
            {

#_DEFAULT => Foswiki::Func::getPubUrlPath().'/'.$Foswiki::cfg{UsersWebName}.'/'.$params->{_DEFAULT}.'/'.$picture->{value},
                web      => $iweb,
                topic    => $itopic,
                _DEFAULT => $image,
                alt      => " ",
                height   => $size
            }
        );
    }
    return $linkText;
}

sub renderWikiWordHandler {
    my ( $linkText, $hasExplicitLinkLabel, $web, $topic ) = @_;

    if (    #test if its a baseusermapper user
            ( $web eq $Foswiki::cfg{UsersWebName} )
        and ( $linkText eq $topic )
        and Foswiki::Func::wikiToUserName($topic)
        and ( not Foswiki::Func::isGroupMember( 'BaseGroup', $topic ) )
      )
    {
        $linkText =
          AVATAR( $Foswiki::Plugins::SESSION, { _DEFAULT => $topic } )
          . $linkText;
    }

    return $linkText;
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: SvenDowideit

Copyright (C) 2011 Sven Dowideit http://fosiki.com

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
