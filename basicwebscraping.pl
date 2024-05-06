#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;

# Function to perform HTTP request and return response content
sub fetch_url_content {
    my ($url) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/5.0");

    my $response = $ua->get($url);

    if ($response->is_success) {
        return $response->decoded_content;
    } else {
        die "Failed to fetch URL: " . $response->status_line;
    }
}

# Function to extract links from HTML content
sub extract_links {
    my ($html_content) = @_;

    my $tree = HTML::TreeBuilder->new_from_content($html_content);

    my @links = $tree->look_down(_tag => 'a');
    my @urls;
    foreach my $link (@links) {
        push @urls, $link->attr('href');
    }

    $tree->delete;

    return @urls;
}

# Main function
sub main {
    my $url = shift @ARGV or die "Usage: $0 URL\n";

    my $content = fetch_url_content($url);
    my @links = extract_links($content);

    print "Found ", scalar(@links), " links on $url:\n";
    foreach my $link (@links) {
        print "$link\n";
    }
}

# Run main function
main();
