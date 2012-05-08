# CQRS Journey => PDF

Ruby script for generating a PDF of the Microsoft patterns & practices [CQRS Journey documentation](https://github.com/mspnp/cqrs-journey-doc/).

This is entirely *unofficial* and is in no way endorsed by Microsoft or the patterns & practices team. However I found it useful to create a PDF from the work-in-progress documentation to allow reading on my iPad.

## Dependencies

Uses the [gimli](https://github.com/walle/gimli/) Ruby gem for converting markup, such as Markdown formatted text, to PDF. Gimli uses [PDFKit](https://github.com/pdfkit/PDFKit) for PDF generation, which itself is a thin wrapper around [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).

Fonts used are [Calluna](http://www.exljbris.com/calluna.html) and [Calluna Sans](http://www.exljbris.com/callunasans.html); both are freely available to download.

## Copyright

CQRS Journey documentation is © 2012 Microsoft. All rights reserved.