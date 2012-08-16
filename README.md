# CQRS Journey => PDF

Ruby script for generating PDFs from the Microsoft patterns & practices [CQRS Journey documentation](https://github.com/mspnp/cqrs-journey-doc/).

This is entirely *unofficial* and is in no way endorsed by Microsoft or the patterns & practices team. However I found it useful to create a PDF from the documentation to allow reading on my iPad.

## Downloads

Download a pre-generated copy of the final CQRS Journey document.

* [CQRS Journey](https://github.com/downloads/slashdotdash/cqrs-journey-pdf/mspnp-cqrs-journey.pdf) (PDF)

## Dependencies

Uses the [gimli](https://github.com/walle/gimli/) Ruby gem for converting markup, such as Markdown formatted text, to PDF. Gimli uses [PDFKit](https://github.com/pdfkit/PDFKit) for PDF generation, which itself is a thin wrapper around [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).

[Pygments](http://pygments.org/) the Python syntax highlighter is optionally used to prettify the C# source code.

Requires git for cloning/pulling the CQRS doc repository from github.

Fonts used are [Calluna](http://www.exljbris.com/calluna.html) and [Calluna Sans](http://www.exljbris.com/callunasans.html); both are freely available to download.

## Usage

Install dependencies.

	gem install gimli
	
Optionally, install Pygments.	
	
Clone the CQRS documentation repository.

	git clone https://github.com/mspnp/cqrs-journey-doc.git
	git pull  # update to latest as required
	
Generate PDFs of the README, Journey and Reference documents.

	ruby generate.rb /path/to/cqrs-journey-doc/ /path/to/pdf/destination/

## Copyright

CQRS Journey documentation is © 2012 Microsoft. All rights reserved.