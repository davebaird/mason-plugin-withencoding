# NAME

Mason::Plugin::WithEncoding - add encoding support to Poet/Mason apps

# VERSION

Version 0.01

# SYNOPSIS

    In your Poet config file:
    
        mason:
          extra_plugins:
            - WithEncoding
            
        server.encoding.request: UTF-8
        server.encoding.response: UTF-8
        server.default_content_type: text/html; charset=UTF-8

# DESCRIPTION

To decode the request, the plugin loads [Plack::Request::WithEncoding](https://metacpan.org/pod/Plack::Request::WithEncoding) and 
configures it with the encoding specified in `server.encoding.request`. If no 
such setting is found, the request is not decoded. This matches the default 
behaviour of Poet/Mason, but is different from [Plack::Request::WithEncoding](https://metacpan.org/pod/Plack::Request::WithEncoding), 
(which would normally default to UTF-8).

Output generated by your Mason templates is encoded according to the setting 
in `server.encoding.response`. If no such setting is found, the response is not 
encoded. This is the default behaviour of Poet/Mason. 

The content-type default header is set according to `server.default_content_type`. 
If no such setting is found, the default header is `text/html`, as in the default 
Poet/Mason setup. This tells the client what encoding to use when decoding our 
content, and also (AFAIK) tells the client what encoding to use when sending us 
data. 

Output sent through `send_json` is also encoded and the content-type header 
set accordingly.

## Caveat

If you are using Mason outside of a [Poet](https://metacpan.org/pod/Poet) environment, the plugin will only 
encode the output. In a [Poet](https://metacpan.org/pod/Poet) environment, it also decodes the request.

## Some background

    http://stackoverflow.com/questions/27806684/mason2-wrong-utf8-encoding-with-the-go-method
    http://stackoverflow.com/questions/5858596/how-to-make-mason2-utf-8-clean
    https://www.mail-archive.com/mason-users@lists.sourceforge.net/msg03450.html

## TODO 

Check the FillInForm filter, maybe convert to use [HTML::FillInForm::ForceUTF8](https://metacpan.org/pod/HTML::FillInForm::ForceUTF8).

# AUTHOR

David R. Baird, `<dave at zerofive.co.uk >`

# BUGS

Please report any bugs or feature requests to `bug-mason-plugin-withencoding at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mason-Plugin-WithEncoding](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mason-Plugin-WithEncoding).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mason::Plugin::WithEncoding

You can also look for information at:

- Github (report bugs here)

    [https://github.com/davebaird/mason-plugin-withencoding](https://github.com/davebaird/mason-plugin-withencoding)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Mason-Plugin-WithEncoding](http://annocpan.org/dist/Mason-Plugin-WithEncoding)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Mason-Plugin-WithEncoding](http://cpanratings.perl.org/d/Mason-Plugin-WithEncoding)

- Search CPAN

    [http://search.cpan.org/dist/Mason-Plugin-WithEncoding/](http://search.cpan.org/dist/Mason-Plugin-WithEncoding/)

# ACKNOWLEDGEMENTS

# LICENSE AND COPYRIGHT

Copyright 2016 David R. Baird.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
