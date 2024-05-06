#!/usr/bin/env perl

use Mojolicious::Lite;
use LWP::UserAgent;
use HTML::TreeBuilder;

# Helper function to fetch URL content
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

# Helper function to extract links from HTML content
sub extract_links {
    my ($html_content) = @_;

    my $tree = HTML::TreeBuilder->new_from_content($html_content);

    my @links = $tree->look_down(_tag => 'a');
    my @urls;
    foreach my $link (@links) {
        push @urls, $link->attr('href');
    }

    $tree->delete;

    return \@urls;
}

# Route for the main page
get '/' => 'index';

# Route for processing form submission
post '/scrape' => sub {
    my $c = shift;

    my $url = $c->param('url') || '';
    my $content = fetch_url_content($url);
    my $links = extract_links($content);

    $c->stash(links => $links);
    $c->render(template => 'result');
};

app->start;

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
<head>
    <title>Web Scraping Tool</title>
</head>
<body>
    <h1>Web Scraping Tool</h1>
    <form action="/scrape" method="post">
        <label for="url">Enter URL to Scrape:</label>
        <input type="text" id="url" name="url">
        <button type="submit">Scrape</button>
    </form>
</body>
</html>

@@ result.html.ep
<!DOCTYPE html>
<html>
<head>
    <title>Scraped Links</title>
</head>
<body>
    <h1>Scraped Links</h1>
    <ul>
    % foreach my $link (@$links) {
        <li><%= $link %></li>
    % }
    </ul>
    <a href="/">Back to Home</a>
</body>
</html>
