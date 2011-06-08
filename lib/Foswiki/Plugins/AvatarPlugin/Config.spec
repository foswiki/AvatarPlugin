# ---+ Extensions
# ---++ AvatarPlugin
# ---+++ UsePersonalInfoAddOn picture
# **BOOLEAN**
# don't use a remote avatar server, use the images selected for PersonalInfoAddon
$Foswiki::cfg{AvatarPlugin}{UsePersonalInfoAddOn} = $FALSE;

# ---+++ AvatarServerBaseUrl
# **STRING 80**
# Url Prefix to use for avatar services
# libravatar -  http://cdn.libravatar.org/avatar/
# gravatar - http://www.gravatar.com/avatar/
$Foswiki::cfg{AvatarPlugin}{AvatarServerBaseUrl} = 'http://cdn.libravatar.org/avatar/';
