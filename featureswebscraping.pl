#!/usr/bin/env perl

use Mojolicious::Lite;
use Mojo::UserAgent;
use Mojo::DOM;

# Route for the main page
get '/' => 'index';

# Route for processing form submission
post '/scrape' => sub {
    my $c = shift;

    my $url = $c->param('url') || '';
    my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($url)->result;

    # Extract HTTP headers
    my $headers = $res->headers->to_string;

    # Extract and analyze form submissions
    my $dom = Mojo::DOM->new($res->body);
    my @form_actions;
    $dom->find('form')->each(sub {
        my $action = $_->attr('action') || $url;
        push @form_actions, $action;
    });

    # Execute JavaScript (requires a headless browser like PhantomJS or Selenium)
    # Example:
    # my $js_content = $ua->get($url)->result->dom->at('script')->text;

    # Content analysis (placeholder for more advanced analysis)
    my $content = $res->body;
    my @sensitive_info; # Placeholder for sensitive information found
    push @sensitive_info, 'API key: 123456' if $content =~ /API key: (\w+)/;

    $c->stash(headers => $headers, form_actions => \@form_actions, sensitive_info => \@sensitive_info);
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
    <title>Scraped Data</title>
</head>
<body>
    <h1>Scraped Data</h1>
    <h2>HTTP Headers:</h2>
    <pre><%= $headers %></pre>

    <h2>Form Actions:</h2>
    <ul>
    % foreach my $action (@$form_actions) {
        <li><%= $action %></li>
    % }
    </ul>

    <h2>Sensitive Information:</h2>
    <ul>
    % foreach my $info (@$sensitive_info) {
        <li><%= $info %></li>
    % }
    </ul>

    <a href="/">Back to Home</a>
</body>
</html>
