=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::Component::Tools::Blast::InputForm;

use strict;
use warnings;

use EnsEMBL::Web::BlastConstants qw(:all);

use parent qw(EnsEMBL::Web::Component::Tools::Blast);

sub content {
  my $self          = shift;
  my $hub           = $self->hub;
  my $sd            = $hub->species_defs;
  my $object        = $self->object;
  my $form_params   = $object->get_blast_form_options;
  my $options       = delete $form_params->{'options'};
  my $combinations  = delete $form_params->{'combinations'};
  my $species       = $hub->species;
     $species       = $hub->get_favourite_species->[0] if $species =~ /multi|common/i;
  my $edit_jobs     = ($hub->function || '') eq 'Edit' ? $object->get_edit_jobs_data : [];

  if (!@$edit_jobs && (my $existing_seq = $hub->param('query_sequence'))) { # If coming from "BLAST this sequence" link
    $edit_jobs = [ {'sequence' => {'sequence' => $existing_seq}} ];
  }

  my $form          = $self->new_tool_form('Blast', {'class' => 'blast-form'});
  my $fieldset      = $form->add_fieldset;

  $fieldset->add_hidden({
    'name'            => 'valid_combinations',
    'value'           => $combinations
  });

  $fieldset->add_hidden({
    'name'            => 'max_sequence_length',
    'value'           => MAX_SEQUENCE_LENGTH,
  });

  $fieldset->add_hidden({
    'name'            => 'dna_threshold_percent',
    'value'           => DNA_THRESHOLD_PERCENT,
  });

  $fieldset->add_hidden({
    'name'            => 'max_number_sequences',
    'value'           => MAX_NUM_SEQUENCES,
  });

  $fieldset->add_hidden({
    'name'            => 'edit_jobs',
    'value'           => $self->jsonify($edit_jobs)
  });

  $fieldset->add_hidden({
    'name'            => 'read_file_url',
    'value'           => $hub->url('Json', {'function' => 'read_file'})
  });

  $fieldset->add_hidden({
    'name'            => 'fetch_sequence_url',
    'value'           => $hub->url('Json', {'function' => 'fetch_sequence'})
  });

  my $query_seq_field = $fieldset->add_field({
    'label'           => 'Sequence data',
    'field_class'     => '_adjustable_height',
    'helptip'         => 'Enter sequence as plain text or in FASTA format, or enter a sequence ID or accession from EnsEMBL, EMBL, UniProt or RefSeq',
    'elements'        => [{
      'type'            => 'div',  # container used by js for adding sequence divs
      'element_class'   => '_sequence js_sequence_wrapper hidden',
    }, {
      'type'            => 'div',  # other sequence input elements will get wrapped in this one later
      'element_class'   => '_sequence_field',
      'children'        => [{'node_name' => 'div', 'class' => 'query_sequence_wrapper'}]
    }, {
      'type'            => 'text',
      'value'           =>  sprintf('Maximum of %s sequences (type in plain text, FASTA or sequence ID)', MAX_NUM_SEQUENCES),
      'class'           => 'inactive query_sequence',
      'name'            => 'query_sequence',
    }, {
      'type'            => 'noedit',
      'value'           => 'Or upload sequence file',
      'no_input'        => 1,
      'element_class'   => 'file_upload_element'
    }, {
      'type'            => 'file',
      'name'            => 'query_file',
      'element_class'   => 'file_upload_element'
    }, {
      'type'            => 'radiolist',
      'name'            => 'query_type',
      'values'          => $options->{'query_type'},
    }]
  });
  my $query_seq_elements = $query_seq_field->elements;

  # add a close button to the textarea element
  $query_seq_elements->[2]->prepend_child('span', {'class' => 'sprite cross_icon _ht', 'title' => 'Cancel'});

  # wrap the sequence input elements
  $query_seq_elements->[1]->first_child->append_children(map { $query_seq_elements->[$_]->remove_attribute('class', $query_seq_field->CSS_CLASS_ELEMENT_DIV); $query_seq_elements->[$_]; } 2..4);

  my $search_against_field = $fieldset->add_field({
    'label'           => 'Search against',
    'field_class'     => '_adjustable_height',
    'elements'        => [{
      'type'            => 'dropdown',
      'name'            => 'species',
      'values'          => $options->{'species'},
      'value'           => $species,
      'multiple'        => 1
    }]
  });

  for (@{$options->{'db_type'}}) {

    $search_against_field->add_element({
      'type'            => 'radiolist',
      'name'            => 'db_type',
      'element_class'   => 'blast_db_type',
      'values'          => [ $_ ],
      'inline'          => 1
    });

    $search_against_field->add_element({
      'type'            => 'dropdown',
      'name'            => "source_$_->{'value'}",
      'element_class'   => 'blast_source',
      'values'          => $options->{'source'}{$_->{'value'}},
      'inline'          => 1
    });
  }

  $fieldset->add_field({
    'label'           => 'Search tool',
    'elements'        => [{
      'type'            => 'dropdown',
      'name'            => 'search_type',
      'class'           => '_stt',
      'values'          => $options->{'search_type'}
    }]
  });

  $fieldset->add_field({
    'label'           => 'Description (optional):',
    'type'            => 'string',
    'name'            => 'description',
    'size'            => '160',
  });

  # Advanced config options
  $form->add_fieldset('Configuration options');

  my $config_fields   = CONFIGURATION_FIELDS;
  my $config_defaults = CONFIGURATION_DEFAULTS;

  my @search_types    = map $_->{'value'}, @{$options->{'search_type'}};
  my %stt_classes     = map {$_ => "_stt_$_"} @search_types; # class names for selectToToggle

  while (my ($config_type, $config_field_group) = splice @$config_fields, 0, 2) {
    my $config_title    = ucfirst "$config_type options:" =~ s/_/ /gr;
    my $config_wrapper  = $form->append_child('div', {
      'class'       => 'extra_configs_wrapper',
      'children'    => [{
        'node_name'   => 'div',
        'class'       => 'extra_configs_button',
        'children'    => [{
          'node_name'   => 'a',
          'rel'         => "_blast_configs_$config_type",
          'class'       => [qw(_slide_toggle toggle set_cookie closed)],
          'href'        => "#Configuration_$config_type",
          'inner_HTML'  => $config_title
        }]
      }, {
        'node_name'   => 'div',
        'class'       => "extra_configs _blast_configs_$config_type toggleable hidden"
      }]
    });

    my $fieldset        = $config_wrapper->last_child->append_child($form->add_fieldset); # moving it from the form to the config div
    my %wrapper_class;

    while (my ($element_name, $element_params) = splice @$config_field_group, 0, 2) {

      my $label         = delete $element_params->{'label'} // '';
      my %field_class;
      my @elements;

      ## add one element for each with its own default value for each valid search type
      foreach my $search_type_value (@search_types) {
        for ($search_type_value, 'all') {
          if (exists $config_defaults->{$_}{$element_name}) {
            my $element_class = $stt_classes{$search_type_value};
            push @elements, {
              %{$self->deepcopy($element_params)},
              'name'          => "${search_type_value}__${element_name}",
              'value'         => $config_defaults->{$_}{$element_name},
              'element_class' => $element_class
            };
            $field_class{$element_class}    = 1; # adding same class to the field makes sure the field is only visible if at least one of the elements is visible
            $wrapper_class{$element_class}  = 1; # adding same class to the config wrapper div makes sure the div is only visible if at least one of the field is visible
            last;
          }
        }
      }

      my $field = $fieldset->add_field({ 'label' => $label, 'elements' => \@elements});
      $field->set_attribute('class', [ keys %field_class ]) unless keys %field_class == keys %stt_classes; # if all classes are there, this field is actually never hidden.
    }

    $config_wrapper->set_attribute('class', [ keys %wrapper_class ]) unless scalar keys %wrapper_class == scalar keys %stt_classes; # if all classes are there, this wrapper div is actually never hidden.
  }

  # add the 'Run' button in a new fieldset
  $self->add_buttons_fieldset($form, {'reset' => 'Clear', 'cancel' => 'Cancel'});

  return sprintf('<div class="hidden _tool_new"><p><a class="button _change_location" href="%s">New Search</a></p></div><div class="hidden _tool_form_div"><h2>Create new ticket:</h2><input type="hidden" class="panel_type" value="BlastForm" />%s</div>',
    $hub->url({'function' => ''}),
    $form->render
  );
}

1;

