#!/usr/bin/env ruby
# encoding: utf-8

require_relative "support"

config = Spotify::SessionConfig.new({
  api_version: Spotify::API_VERSION.to_i,
  application_key: $appkey,
  cache_location: ".spotify/",
  settings_location: ".spotify/",
  user_agent: "spotify for ruby",
  callbacks: nil,
})

$logger.info "Creating session."
$session = Support.create_session(config)

$logger.info "Created! Logging in."
Spotify.session_login($session, $username, $password, false, $blob)

$logger.info "Log in requested. Waiting forever until logged in."
Support.poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."

track_uri = Support.prompt("Please enter a track URI", "spotify:track:1612JQ4JxS8bm5ky53N3bH")
link = Spotify.link_create_from_string(track_uri)

if link.null?
  $logger.error "Invalid URI. Aborting."
  abort
elsif (link_type = Spotify.link_type(link)) != :track
  $logger.error "Was #{link_type} URI. Needs track. Aborting."
  abort
else
  track = Spotify.link_as_track(link)
end

$logger.info "Attempting to load track. Waiting forever until successful."
Support.poll($session) { Spotify.track_is_loaded(track) }
$logger.info "Track loaded."

puts Spotify.track_name(track)
