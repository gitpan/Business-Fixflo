package Business::Fixflo::Resource;

=head1 NAME

Business::Fixflo::Resource

=head1 DESCRIPTION

This is a base class for Fixflo resource classes, it implements common
behaviour. You shouldn't use this class directly, but extend it instead.

=cut

use Moo;
use Carp qw/ confess /;
use JSON ();

=head1 ATTRIBUTES

    client
    url

=cut

has client => (
    is       => 'ro',
    isa      => sub {
        confess( "$_[0] is not a Business::Fixflo::Client" )
            if ref $_[0] ne 'Business::Fixflo::Client'
    },
    required => 1,
);

has [ qw/ url / ] => (
    is      => 'rw',
	lazy    => 1,
	default => sub {
		my ( $self ) = @_;
        return join(
			'/',
			$self->client->base_url . $self->client->api_path,
			( split( ':',ref( $self ) ) )[-1],
			$self->Id
		);
	},
);

=head1 METHODS

=head2 to_hash

Returns a hash representation of the object.

    my %data = $Issue->to_hash;

=head2 to_json

Returns a json string representation of the object.

    my $json = $Issue->to_json;

=cut

sub to_hash {
    my ( $self ) = @_;

    my %hash = %{ $self };
    delete( $hash{client} );
    return %hash;
}

sub to_json {
    my ( $self ) = @_;
    return JSON->new->canonical->encode( { $self->to_hash } );
}

sub get {
	my ( $self ) = @_;

	my $data = $self->client->api_get( $self->url );

	foreach my $attr ( keys( %{ $data } ) ) {
		$self->$attr( $data->{$attr} );
	}

	return $self;
}

=head1 AUTHOR

Lee Johnson - C<leejo@cpan.org>

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

    https://github.com/leejo/business-fixflo

=cut

1;

# vim: ts=4:sw=4:et
