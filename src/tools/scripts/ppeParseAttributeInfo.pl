#!/usr/bin/perl -w
# IBM_PROLOG_BEGIN_TAG
# This is an automatically generated prolog.
#
# $Source: src/tools/scripts/ppeParseAttributeInfo.pl $
#
# OpenPOWER sbe Project
#
# Contributors Listed Below - COPYRIGHT 2015,2017
# [+] International Business Machines Corp.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# IBM_PROLOG_END_TAG
# Purpose:  This perl script will parse HWP Attribute XML files
# and add attribute information to a file called attribute_ids.H

use strict;

sub help {
    print ("Usage: ppeParseAttributeInfo.pl <output dir> <attr-xml-file1> [<attr-xml-file2> ...]\n");
    print ("  This perl script will parse attribute XML files and create the following files:\n");
    print ("  - attribute_ids.H.          Contains IDs, type, value enums and other information\n");
    print ("  - fapi2ChipEcFeature.C.         Contains a function to query chip EC features\n");
    print ("  - fapi2AttributePlatCheck.H.    Contains compile time checks that all attributes are\n");
    print ("                                  handled by the platform\n");
    print ("  - fapi2AttributesSupported.html Contains the HWPF attributes supported\n");
    print ("  - fapi2AttrInfo.csv             Used to process Attribute Override Text files\n");
    print ("  - fapi2AttrEnumInfo.csv         Used to process Attribute Override Text files\n");
}

my $DEBUG = 0;
my $VERBOSE = 0;
my $help = 0;

#------------------------------------------------------------------------------
# Print Command Line Help
#------------------------------------------------------------------------------
my $numArgs = $#ARGV + 1;
if ($numArgs < 2)
{
    print ("Invalid number of arguments\n\n");
    help();
    exit(1);
}

#------------------------------------------------------------------------------
# Specify perl modules to use
#------------------------------------------------------------------------------
use Getopt::Long;
use Digest::MD5 qw(md5_hex);
use XML::Simple;
my $xml = new XML::Simple (KeyAttr=>[]);

GetOptions ("verbose" => \$VERBOSE,
            "help" => \$help,
            "debug" => \$DEBUG,
           );

if ($help)
{
    help();
    exit(0);
}

if ($DEBUG)
{
    print "DEBUG enabled!!!!\n";
}

# Uncomment to enable debug output
# use Data::Dumper;

#------------------------------------------------------------------------------
# Set PREFERRED_PARSER to XML::Parser. Otherwise it uses XML::SAX which contains
# bugs that result in XML parse errors that can be fixed by adjusting white-
# space (i.e. parse errors that do not make sense).
#------------------------------------------------------------------------------
$XML::Simple::PREFERRED_PARSER = 'XML::Parser';

#------------------------------------------------------------------------------
# Open output files for writing
#------------------------------------------------------------------------------
my $aiFile = $ARGV[0];
$aiFile .= "/";
$aiFile .= "attribute_ids.H";
open(AIFILE, ">", $aiFile);

my $echFile = $ARGV[0];
$echFile .= "/";
$echFile .= "fapi2_chip_ec_feature.H";
open(ECHFILE, ">", $echFile);

my $acFile = $ARGV[0];
$acFile .= "/";
$acFile .= "fapi2AttributePlatCheck.H";
open(ACFILE, ">", $acFile);

my $asFile = $ARGV[0];
$asFile .= "/";
$asFile .= "fapi2AttributesSupported.html";
open(ASFILE, ">", $asFile);

my $itFile = $ARGV[0];
$itFile .= "/";
$itFile .= "fapi2AttrInfo.csv";
open(ITFILE, ">", $itFile);

my $etFile = $ARGV[0];
$etFile .= "/";
$etFile .= "fapi2AttrEnumInfo.csv";
open(ETFILE, ">", $etFile);

#------------------------------------------------------------------------------
# Print Start of file information to fapiAttributeIds.H
#------------------------------------------------------------------------------
print AIFILE "// attribute_ids.H\n";
print AIFILE "// This file is generated by perl script fapiParseAttributeInfo.pl\n\n";
print AIFILE "#ifndef FAPI2ATTRIBUTEIDS_H_\n";
print AIFILE "#define FAPI2ATTRIBUTEIDS_H_\n\n";
print AIFILE "#ifndef __ASSEMBLER__\n\n";
print AIFILE "#include <target.H>\n";
print AIFILE "#include <target_types.H>\n\n";
print AIFILE "namespace fapi2\n";
print AIFILE "{\n\n";
print AIFILE "\/**\n";
print AIFILE " * \@brief Enumeration of attribute IDs\n";
print AIFILE " *\/\n";
print AIFILE "enum AttributeId\n{\n";

#------------------------------------------------------------------------------
# Print Start of file information to fapi2_chip_ec_feature.H
#------------------------------------------------------------------------------
print ECHFILE "// This file is generated by perl script parseAttributeInfo.pl\n";
print ECHFILE "// It implements the fapi2_chip_ec_feature function\n\n";
print ECHFILE "#ifndef __FAPI2_CHIP_EC_FEATURE_H_\n";
print ECHFILE "#define __FAPI2_CHIP_EC_FEATURE_H_\n";
print ECHFILE "#include <fapi2_attribute_service.H>\n";
print ECHFILE "#include <attribute_ids.H>\n";
print ECHFILE "namespace fapi2\n";
print ECHFILE "{\n\n";
print ECHFILE "// create a unique type from an int ( or attribute id) \n";
print ECHFILE "template<int I>\n";
print ECHFILE  "struct int2Type {\n";
print ECHFILE  "enum { value = I };\n";
print ECHFILE "};\n";
print ECHFILE "class AttributeRC\n";
print ECHFILE "{\n";
print ECHFILE "    public:\n";
print ECHFILE "    AttributeRC() : value(FAPI2_RC_SUCCESS){}\n";
print ECHFILE "    AttributeRC(uint32_t i_val) : value(i_val){}\n";
print ECHFILE "    operator uint32_t (){return value;}\n";
print ECHFILE "    operator ReturnCode (){return value;}\n";
print ECHFILE "    private:\n";
print ECHFILE "    uint32_t value;\n";
print ECHFILE "};\n";
print ECHFILE "void queryChipEcAndName(\n";
print ECHFILE "                    const Target<fapi2::TARGET_TYPE_PROC_CHIP>& i_target,\n";
print ECHFILE "                    fapi2::ATTR_NAME_Type& , fapi2::ATTR_EC_Type & );\n\n";
print ECHFILE "template<int T>\n";
print ECHFILE "AttributeRC queryChipEcFeature(int2Type<T> id,\n";
print ECHFILE "                    const Target<fapi2::TARGET_TYPE_PROC_CHIP>& i_target,\n";
print ECHFILE "                    uint8_t & o_hasFeature)\n";
print ECHFILE "{\n";
print ECHFILE "    fapi2::ATTR_NAME_Type l_chipName;\n";
print ECHFILE "    fapi2::ATTR_EC_Type l_chipEc;\n\n";
print ECHFILE "    o_hasFeature = 0;\n\n";
print ECHFILE "    queryChipEcAndName(i_target, l_chipName, l_chipEc);\n";
print ECHFILE "    o_hasFeature = hasFeature(int2Type<T>(), l_chipName, l_chipEc);\n";
print ECHFILE "    return FAPI2_RC_SUCCESS;\n";
print ECHFILE "}\n\n";

#------------------------------------------------------------------------------
# Print Start of file information to fapiAttributePlatCheck.H
#------------------------------------------------------------------------------
print ACFILE "// fapiAttributePlatCheck.H\n";
print ACFILE "// This file is generated by perl script fapiParseAttributeInfo.pl\n";
print ACFILE "// A platform can include it to ensure that it handles all HWPF\n";
print ACFILE "// attributes\n\n";
print ACFILE "#ifndef FAPIATTRIBUTEPLATCHECK_H_\n";
print ACFILE "#define FAPIATTRIBUTEPLATCHECK_H_\n\n";

#------------------------------------------------------------------------------
# Print Start of file information to fapiAttributesSupported.html
#------------------------------------------------------------------------------
print ASFILE "<html>\n";
print ASFILE "<body>\n\n";
print ASFILE "<!-- fapiAttributesSupported.html -->\n";
print ASFILE "<!-- This file is generated by perl script fapiParseAttributeInfo.pl -->\n";
print ASFILE "<!-- It lists all HWPF attributes supported -->\n\n";
print ASFILE "<h4>HWPF Attributes supported by this build.</h4>\n";
print ASFILE "<table border=\"4\">\n";
print ASFILE "<tr><th>Attribute ID</th><th>Attribute Description</th></tr>";

#------------------------------------------------------------------------------
# Print Start of file information to fapiAttrInfo.csv
#------------------------------------------------------------------------------
print ITFILE "# fapiAttrInfo.csv\n";
print ITFILE "# This file is generated by perl script fapiParseAttributeInfo.pl\n";
print ITFILE "# It lists information about FAPI attributes and is used to\n";
print ITFILE "# process FAPI Attribute text files (overrides/syncs)\n";
print ITFILE "# Format:\n";
print ITFILE "# <FAPI-ATTR-ID-STR>,<LAYER-ATTR-ID-STR>,<ATTR-ID-VAL>,<ATTR-TYPE>\n";
print ITFILE "# Note that for the AttributeTanks at the FAPI layer, the\n";
print ITFILE "# FAPI-ATTR-ID-STR and LAYER-ATTR-ID-STR will be identical\n";

#------------------------------------------------------------------------------
# Print Start of file information to fapiAttrEnumInfo.csv
#------------------------------------------------------------------------------
print ETFILE "# fapiAttrEnumInfo.csv\n";
print ETFILE "# This file is generated by perl script fapiParseAttributeInfo.pl\n";
print ETFILE "# It lists information about FAPI attribute enumeratorss and is\n";
print ETFILE "# used to process FAPI Attribute text files (overrides/syncs)\n";
print ETFILE "# Format:\n";
print ETFILE "# <ENUM-STR>,<ENUM-VAL>\n";

my %attrIdHash;  # Records which Attribute IDs have been used
my %attrValHash; # Records which Attribute values have been used

#------------------------------------------------------------------------------
# For each XML file
#------------------------------------------------------------------------------
#my $argfile = "p9_ppe_attributes.xml";
my $argfile = $ARGV[1];
if ($DEBUG) { print "DEBUG:: XML filter file - $argfile\n" }
my $entries = $xml->XMLin($argfile, ForceArray => ['entry']);
foreach my $entr (@{$entries->{entry}}) {

    my $inname = $entr->{name};
    if ($DEBUG) { print "DEBUG:: entr->file = $entr->{file}; \n" }

    foreach my $argnum (2 .. $#ARGV)
    {
        my $infile = $ARGV[$argnum];

        # read XML file. The ForceArray option ensures that there is an array of
        # elements even if there is only one such element in the file
        my $attributes = $xml->XMLin($infile, ForceArray => ['attribute', 'chip']);

        if ($DEBUG) { print "DEBUG:: File: ", $infile, "\n", Dumper($attributes), "\n"; }

        #--------------------------------------------------------------------------
        # For each Attribute
        #--------------------------------------------------------------------------
        foreach my $attr (@{$attributes->{attribute}})
        {

            #print "?    $attr->{id}, $inname\n";

            if($attr->{id} eq $inname) {

            #print "yes    $attr->{id}, $inname\n";

            #----------------------------------------------------------------------
            # Print the Attribute ID and calculated value to fapiAttributeIds.H and
            # fapiAttributeIds.txt. The value for an attribute is a hash value
            # generated from the attribute name, this ties a specific value to a
            # specific attribute name. This is done for Cronus so that if a HWP is
            # not recompiled against a new eCMD/Cronus version where the attributes
            # have changed then there will not be a mismatch in enumerator values.
            # This is a 28bit hash value because the Initfile compiler has a
            # requirement that the top nibble of the 32 bit attribute ID be zero to
            # store flags
            #----------------------------------------------------------------------
            if (! exists $attr->{id})
            {
                print ("fapiParseAttributeInfo.pl ERROR. Attribute 'id' missing in $infile\n");
                exit(1);
            }

            if (exists($attrIdHash{$attr->{id}}))
            {
                # Two different attributes with the same id!
                print ("fapiParseAttributeInfo.pl ERROR. Duplicate Attribute id $attr->{id} in $infile\\n");
                exit(1);
            }

            # Calculate a 28 bit hash value.
            my $attrHash128Bit = md5_hex($attr->{id});
            my $attrHash28Bit = substr($attrHash128Bit, 0, 7);

            # Print the attribute ID/value to fapiAttributeIds.H
            print AIFILE "    $attr->{id} = 0x$attrHash28Bit,\n";

            if (exists($attrValHash{$attrHash28Bit}))
            {
                # Two different attributes generate the same hash-value!
                print ("fapiParseAttributeInfo.pl ERROR. Duplicate attr id hash value for $attr->{id} in $infile\ \n");
                exit(1);
            }

            $attrIdHash{$attr->{id}} = $attrHash28Bit;
            $attrValHash{$attrHash28Bit} = 1;
            }
        };
    }
}

#------------------------------------------------------------------------------
# Print AttributeId enumeration end to fapiAttributeIds.H
#------------------------------------------------------------------------------
print AIFILE "};\n\n";

#------------------------------------------------------------------------------
# Print Attribute Information comment to fapiAttributeIds.H
#------------------------------------------------------------------------------
print AIFILE "\/**\n";
print AIFILE " * \@brief Attribute Information\n";
print AIFILE " *\/\n";


foreach my $entr (@{$entries->{entry}}) {

#    print "    $entr->{file}, $entr->{name}\n";

#    my $infile = $entr->{file};
    my $inname = $entr->{name};

    # read XML file. The ForceArray option ensures that there is an array of
    # elements even if there is only one such element in the file

    foreach my $argnum (2 .. $#ARGV)
    {
        my $infile = $ARGV[$argnum];

        my $attributes = $xml->XMLin($infile, ForceArray => ['attribute', 'chip']);

        # Uncomment to get debug output of all attributes
        if ($DEBUG) { print "DEBUG::  File: ", $infile, "\n", Dumper($attributes), "\n"; }

        #--------------------------------------------------------------------------
        # For each Attribute
        #--------------------------------------------------------------------------
        foreach my $attr (@{$attributes->{attribute}})
        {

            if($attr->{id} eq $inname) {

            #----------------------------------------------------------------------
            # Print a comment with the attribute ID fapiAttributeIds.H
            #----------------------------------------------------------------------
            print AIFILE "/* $attr->{id} */\n";

            #----------------------------------------------------------------------
            # Print the AttributeId and description to fapiAttributesSupported.html
            #----------------------------------------------------------------------
            if (! exists $attr->{description})
            {
                print ("fapiParseAttributeInfo.pl ERROR. Attribute 'description' missing for $attr->{id} in $infile\n");
                exit(1);
            }


            #----------------------------------------------------------------------
            # Figure out the attribute array dimensions (if array)
            #----------------------------------------------------------------------
            my $arrayDimensions = "";
            my $numArrayDimensions = 0;
            if ($attr->{array})
            {
                # Remove leading whitespace
                my $dimText = $attr->{array};
                $dimText =~ s/^\s+//;

                # Split on commas or whitespace
                my @vals = split(/\s*,\s*|\s+/, $dimText);

                foreach my $val (@vals)
                {
                    $arrayDimensions .= "[${val}]";
                    $numArrayDimensions++;
                }
            }

            #----------------------------------------------------------------------
            # Print the typedef for each attribute's val type to fapiAttributeIds.H
            # Print the attribute information to fapiAttrInfo.csv
            #----------------------------------------------------------------------
            if (exists $attr->{chipEcFeature})
            {
                # The value type of chip EC feature attributes is uint8_t
                print AIFILE "typedef uint8_t $attr->{id}_Type;\n";
                print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},u8\n"
            }
            else
            {
                if (! exists $attr->{valueType})
                {
                    print ("fapiParseAttributeInfo.pl ERROR. Att 'valueType' missing for $attr->{id} in $infile\n");
                    exit(1);
                }

                if ($attr->{valueType} eq 'uint8')
                {
                    print AIFILE "typedef uint8_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},u8" .
                                 "$arrayDimensions\n";
                }
                elsif ($attr->{valueType} eq 'uint16')
                {
                    print AIFILE "typedef uint16_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},u8" .
                                 "$arrayDimensions\n";
                }
                elsif ($attr->{valueType} eq 'uint32')
                {
                    print AIFILE "typedef uint32_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},u32" .
                                 "$arrayDimensions\n";
                }
                elsif ($attr->{valueType} eq 'uint64')
                {
                    print AIFILE "typedef uint64_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},u64" .
                                 "$arrayDimensions\n";
                }
                elsif ($attr->{valueType} eq 'int8')
                {
                    print AIFILE "typedef int8_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},8" .
                                 "$arrayDimensions\n";
                }
                 elsif ($attr->{valueType} eq 'int16')
                {
                    print AIFILE "typedef int16_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},32" .
                                 "$arrayDimensions\n";
                }
                elsif ($attr->{valueType} eq 'int32')
                {
                    print AIFILE "typedef int32_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},32" .
                                 "$arrayDimensions\n";
                }
                elsif ($attr->{valueType} eq 'int64')
                {
                    print AIFILE "typedef int64_t $attr->{id}_Type$arrayDimensions;\n";
                    print ITFILE "$attr->{id},$attr->{id},0x$attrIdHash{$attr->{id}},64" .
                                 "$arrayDimensions\n";
                }
                else
                {
                    print ("fapi2ParseAttributeInfo.pl ERROR. valueType not recognized: ");
                    print $attr->{valueType}, " for $attr->{id} in $infile\n";
                    exit(1);
                }
            }

            #----------------------------------------------------------------------
            # Print if the attribute is privileged
            #----------------------------------------------------------------------
            if (exists $attr->{privileged})
            {
                print AIFILE "const bool $attr->{id}_Privileged = true;\n";
            }
            else
            {
                print AIFILE "const bool $attr->{id}_Privileged = false;\n";
            }

            #----------------------------------------------------------------------
            # Print the target type(s) that the attribute is associated with
            #----------------------------------------------------------------------
            if (! exists $attr->{targetType})
            {
                print ("fapiParseAttributeInfo.pl ERROR. Att 'targetType' missing for $attr->{id} in $infile\n");
                exit(1);
            }

            print AIFILE "const fapi2::TargetType $attr->{id}_TargetType = ";

            # Split on commas
            my @targTypes = split(',', $attr->{targetType});
            my $targType = $targTypes[0];
            my $targetTypeCount = 0;

            foreach my $targType (@targTypes)
            {
                # Remove newlines and leading/trailing whitespace
                $targType =~ s/\n//;
                $targType =~ s/^\s+//;
                $targType =~ s/\s+$//;

                # Consider only supported target types. The rest are ignored
                if($targType ~~ ["TARGET_TYPE_PROC_CHIP", "TARGET_TYPE_SYSTEM",
                    "TARGET_TYPE_CORE", "TARGET_TYPE_MCS", "TARGET_TYPE_PERV",
                    "TARGET_TYPE_EQ", "TARGET_TYPE_EX", "TARGET_TYPE_PHB",
                    "TARGET_TYPE_MCBIST", "TARGET_TYPE_MC", "TARGET_TYPE_MI"])
                {
                    if($targetTypeCount != 0)
                    {
                        print AIFILE " | ";
                    }
                    print AIFILE "$targType";
                    $targetTypeCount++;
                }
            }

            if($targetTypeCount == 0)
            {
                print ("fapiParseAttributeInfo.pl ERROR. Unsupported target type $attr->{targetType} for $attr->{id} in $infile\n");
                exit(1);
            }

            print AIFILE ";\n";

            #----------------------------------------------------------------------
            # Print if the attribute is a platInit attribute
            #----------------------------------------------------------------------
            if (exists $attr->{platInit})
            {
                print AIFILE "const bool $attr->{id}_PlatInit = true;\n";
            }
            else
            {
                print AIFILE "const bool $attr->{id}_PlatInit = false;\n";
            }

            #----------------------------------------------------------------------
            # Print if the attribute is a initToZero attribute
            #----------------------------------------------------------------------
            if (exists $attr->{initToZero})
            {
                print AIFILE "const bool $attr->{id}_InitToZero = true;\n";
            }
            else
            {
                print AIFILE "const bool $attr->{id}_InitToZero = false;\n";
            }

            #----------------------------------------------------------------------
            # Print the value enumeration (if specified) to fapiAttributeIds.H and
            # fapiAttributeEnums.txt
            #----------------------------------------------------------------------
            if (exists $attr->{enum})
            {
                print AIFILE "enum $attr->{id}_Enum\n{\n";

                # Values must be separated by commas to allow for values to be
                # specified: <enum>VAL_A = 3, VAL_B = 5, VAL_C = 0x23</enum>
                my @vals = split(',', $attr->{enum});

                foreach my $val (@vals)
                {
                    # Remove newlines and leading/trailing whitespace
                    $val =~ s/\n//;
                    $val =~ s/^\s+//;
                    $val =~ s/\s+$//;

                    # Print the attribute enum to fapiAttributeIds.H
                    print AIFILE "    ENUM_$attr->{id}_${val}";

                    # Print the attribute enum to fapiAttrEnumInfo.csv
                    my $attrEnumTxt = "$attr->{id}_${val}\n";
                    $attrEnumTxt =~ s/ = /,/;
                    print ETFILE $attrEnumTxt;

                    if ($attr->{valueType} eq 'uint64')
                    {
                        print AIFILE "ULL";
                    }

                    print AIFILE ",\n";
                }

                print AIFILE "};\n";
            }

            #----------------------------------------------------------------------
            # Print _GETMACRO and _SETMACRO where appropriate to fapiAttributeIds.H
            #----------------------------------------------------------------------
            if (exists $attr->{chipEcFeature})
            {
                #------------------------------------------------------------------
                # The attribute is a Chip EC Feature, define _GETMACRO to call a
                # fapi function and define _SETMACRO to something that will cause a
                # compile failure if a set is attempted
                #------------------------------------------------------------------
                print AIFILE "#define $attr->{id}_GETMACRO(ID, PTARGET, VAL) \\\n";
                print AIFILE "    PLAT_GET_CHIP_EC_FEATURE_OVERRIDE(ID, PTARGET, VAL) ? fapi2::AttributeRC() : \\\n";
                print AIFILE " fapi2::queryChipEcFeature(fapi2::int2Type<ID>(), PTARGET, VAL)\n";
                print AIFILE "#define $attr->{id}_SETMACRO(ID, PTARGET, VAL) ";
                print AIFILE "CHIP_EC_FEATURE_ATTRIBUTE_NOT_WRITABLE\n";
            }
            elsif (! exists $attr->{writeable})
            {
                #------------------------------------------------------------------
                # The attribute is read-only, define the _SETMACRO to something
                # that will cause a compile failure if a set is attempted
                #------------------------------------------------------------------
                if (! exists $attr->{writeable})
                {
                    print AIFILE "#define $attr->{id}_SETMACRO ATTRIBUTE_NOT_WRITABLE\n";
                }
            }

        #----------------------------------------------------------------------
        # If the attribute is a Chip EC Feature, print the chip EC feature
        # query to fapi2_chip_ec_feature.H
        #----------------------------------------------------------------------
        # Each EC attribute will generate a new inline overloaded version of
        # hasFeature with the attribute specific logic
        if (exists $attr->{chipEcFeature})
        {
            my $chipCount     = 0;
            my $falseIfMatch  = exists $attr->{chipEcFeature}->{falseIfMatch};
            my $noMatchValue  = $falseIfMatch ? 1 : 0;
            my $yesMatchValue = $falseIfMatch ? 0 : 1;

            print ECHFILE " inline uint8_t hasFeature(int2Type<$attr->{id}>,\n";
            print ECHFILE "                       fapi2::ATTR_NAME_Type i_name,\n";
            print ECHFILE "                       fapi2::ATTR_EC_Type i_ec)\n";
            print ECHFILE " {\n";
            print ECHFILE "    uint8_t hasFeature = $noMatchValue;\n\n";
            print ECHFILE "    if(";

            foreach my $chip (@{$attr->{chipEcFeature}->{chip}})
            {
                if (! exists $chip->{name})
                {
                    print ("parseAttributeInfo.pl ERROR. Att 'name' missing\n");
                    exit(1);
                }

                if (! exists $chip->{ec})
                {
                    print ("parseAttributeInfo.pl ERROR. Att 'ec' missing\n");
                    exit(1);
                }

                if (! exists $chip->{ec}->{value})
                {
                    print ("parseAttributeInfo.pl ERROR. Att 'value' missing\n");
                    exit(1);
                }

                if (! exists $chip->{ec}->{test})
                {
                    print ("parseAttributeInfo.pl ERROR. Att 'test' missing\n");
                    exit(1);
                }

                if($chip->{name} eq 'ENUM_ATTR_NAME_CENTAUR')
                {
                    # Skip Centaur chip
                    next;
                }

                $chipCount++;
                my $test;
                if ($chip->{ec}->{test} eq 'EQUAL')
                {
                    $test = '==';
                }
                elsif ($chip->{ec}->{test} eq 'GREATER_THAN')
                {
                    $test = '>';
                }
                elsif ($chip->{ec}->{test} eq 'GREATER_THAN_OR_EQUAL')
                {
                    $test = '>=';
                }
                elsif ($chip->{ec}->{test} eq 'LESS_THAN')
                {
                    $test = '<';
                }
                elsif ($chip->{ec}->{test} eq 'LESS_THAN_OR_EQUAL')
                {
                    $test = '<=';
                }
                else
                {
                    print ("parseAttributeInfo.pl ERROR. test '$chip->{ec}->{test}' unrecognized\n");
                    exit(1);
                }

                if ($chipCount > 1)
                {
                    print ECHFILE " ||\n\t";
                }
                print ECHFILE "((i_name == $chip->{name}) && ";
                print ECHFILE " (i_ec $test $chip->{ec}->{value}))";
            }
            print ECHFILE ")\n";
            print ECHFILE "     {\n";
            print ECHFILE "         hasFeature = $yesMatchValue;\n";
            print ECHFILE "     }\n";
            print ECHFILE "     return hasFeature;\n";
            print ECHFILE " };\n";
        }

            #----------------------------------------------------------------------
            # Print the platform attribute checks to fapiAttributePlatCheck.H
            #----------------------------------------------------------------------
            if (exists $attr->{writeable})
            {
                print ACFILE "#ifndef $attr->{id}_SETMACRO\n";
                print ACFILE "#error Platform does not support set of HWPF attr $attr->{id}\n";
                print ACFILE "#endif\n";
            }

            print ACFILE "#ifndef $attr->{id}_GETMACRO\n";
            print ACFILE "#error Platform does not support get of HWPF attr $attr->{id}\n";
            print ACFILE "#endif\n\n";

            #----------------------------------------------------------------------
            # Print newline between each attribute's info to fapiAttributeIds.H
            #----------------------------------------------------------------------
            print AIFILE "\n";





            }
        };
    }
}

#------------------------------------------------------------------------------
# Print End of file information to fapiAttributeIds.H
#------------------------------------------------------------------------------
print AIFILE "} //fapi2 \n\n";
print AIFILE "#endif // __ASSEMBLER__\n\n";
print AIFILE "#endif\n";

print ECHFILE "}\n";
print ECHFILE "#endif\n";


#------------------------------------------------------------------------------
# Print End of file information to fapiAttributePlatCheck.H
#------------------------------------------------------------------------------
print ACFILE "#endif\n";

#------------------------------------------------------------------------------
# Print End of file information to fapiAttributesSupported.html
#------------------------------------------------------------------------------
print ASFILE "</table>\n\n";
print ASFILE "</body>\n";
print ASFILE "</html>\n";


#------------------------------------------------------------------------------
# Close output files
#------------------------------------------------------------------------------
close(AIFILE);
close(ECHFILE);
close(ACFILE);
close(ASFILE);
close(ITFILE);
close(ETFILE);
