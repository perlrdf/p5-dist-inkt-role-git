package Dist::Inkt::Role::WriteGithubREADME;

our $AUTHORITY = 'cpan:KJETIL';
our $VERSION   = '0.024';

use Moose::Role;
use Pod::Markdown::Github;
use namespace::autoclean;

has source_for_readme => (
        is      => 'ro',
        lazy    => 1,
        default => sub { shift->lead_module },
);

after BUILD => sub {
        my $self = shift;
        unshift @{ $self->targets }, 'README';
};

sub Build_README
{
  my $self = shift;

        
        my $file = $self->targetfile('README.md');
        $file->exists and return $self->log('Skipping %s; it already exists', $file);
        $self->log('Writing Github-flavoured %s', $file);
        
        my $parser = Pod::Markdown::Github->new(output_encoding => 'UTF-8');
		  $parser->output_fh($file->openw_raw);
        
        my $input = $self->source_for_readme;
        unless ($input =~ /\.(pm|pod)$/)
        {
                $input =~ s{::}{/}g;
                $input = "lib/$input.pm";
        }
        $input = $self->sourcefile($input);

        # inherit rights from input pod
        $self->rights_for_generated_files->{'README.md'} ||= [
                $self->_determine_rights($input)
        ] if $self->can('_determine_rights');
		  $parser->parse_file($input->openr_raw);
}

1;
