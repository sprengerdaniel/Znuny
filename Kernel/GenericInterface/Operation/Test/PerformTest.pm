# --
# Kernel/GenericInterface/Operation/Test/PerformTest.pm - GenericInterface test operation interface
# Copyright (C) 2001-2011 OTRS AG, http://otrs.org/
# --
# $Id: PerformTest.pm,v 1.1 2011-02-10 08:45:20 cr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::GenericInterface::Operation::Test::PerformTest;

use strict;
use warnings;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 1.1 $) [1];

=head1 NAME

Kernel::GenericInterface::Operation

=head1 SYNOPSIS

GenericInterface Operation interface.

Operations are called by web service requests from remote
systems.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object.

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Time;
    use Kernel::System::Main;
    use Kernel::System::DB;
    use Kernel::GenericInterface::Operation;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $TimeObject = Kernel::System::Time->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $OperationObject = Kernel::GenericInterface::Operation->new(
        ConfigObject       => $ConfigObject,
        LogObject          => $LogObject,
        DBObject           => $DBObject,
        MainObject         => $MainObject,
        TimeObject         => $TimeObject,
        EncodeObject       => $EncodeObject,

        Operation => 'Ticket::TicketCreate',    # the local operation to use
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (
        qw(DebuggerObject MainObject ConfigObject LogObject EncodeObject TimeObject DBObject)
        )
    {
        return {
            Success      => 0,
            ErrorMessage => "Got no $Needed!",
        } if !$Param{$Needed};

        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

=item Run()

perform the selected Operation.

    my $Result = $OperationObject->Run(
        Data => {                               # data payload before Operation
            ...
        },
    );

    $Result = {
        Success         => 1,                   # 0 or 1
        ErrorMessage    => '',                  # in case of error
        Data            => {                    # result data payload after Operation
            ...
        },
    };

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    # check data - we need a hash ref with at least one entry
    if ( !$Self->_IsNonEmptyHashRef( Data => $Param{Data} ) ) {
        return $Self->_LogAndExit( ErrorMessage => 'Got no Data hash ref with content!' );
    }

    my $ReturnData = $Self->_Test( Data => $Param{Data} );

    # return result
    return $Self->_CleanExit( Data => $ReturnData );
}

=item _LogAndExit()

log specified error message to debug log and return error hash ref

    my $Result = $OperationObject->_LogAndExit(
        ErrorMessage => 'An error occured!', # optional
    );

    $Result = {
        Success      => 0,
        ErrorMessage => 'An error occured!',
    };

=cut

sub _LogAndExit {
    my ( $Self, %Param ) = @_;

    # get message
    my $ErrorMessage = $Param{ErrorMessage} || 'Unspecified error!';

    # log error
    $Self->{DebuggerObject}->DebugLog(
        DebugLevel => 'error',
        Title      => $ErrorMessage,

        # FIXME this should be optional
        Data => $ErrorMessage,
    );

    # return error
    return {
        Success      => 0,
        ErrorMessage => $ErrorMessage,
    };
}

=item _CleanExit()

return hash reference indicating success and containing return data

    my $Result = $OperationObject->_CleanExit(
        Data => {
            ...
        },
    );

    $Result = {
        Success => 1,
        Data    => {
            ...
        },
    };

=cut

sub _CleanExit {
    my ( $Self, %Param ) = @_;

    # check data
    if ( !$Self->_IsNonEmptyHashRef( Data => $Param{Data} ) ) {
        return $Self->_LogAndExit( ErrorMessage => 'Got no Data as hash ref with content!' );
    }

    # return
    return {
        Success => 1,
        Data    => $Param{Data},
    };
}

=item _IsNonEmptyString()

test supplied data to determine if it is a non zero-length string

returns 1 if data matches criteria or undef otherwise

    my $Result = $OperationObject->_IsNonEmptyString(
        Data => 'abc' # data to be tested
    );

=cut

sub _IsNonEmptyString {
    my ( $Self, %Param ) = @_;

    my $TestData = $Param{Data};

    return if !$TestData;
    return if ref $TestData;

    return 1;
}

=item _IsNonEmptyHashRef()

test supplied data to determine if it is a hash reference containing data

returns 1 if data matches criteria or undef otherwise

    my $Result = $OperationObject->_IsNonEmptyHashRef(
        Data => { 'key' => 'value' } # data to be tested
    );

=cut

sub _IsNonEmptyHashRef {
    my ( $Self, %Param ) = @_;

    my $TestData = $Param{Data};

    return if !$TestData;
    return if ref $TestData ne 'HASH';
    return if !%{$TestData};

    return 1;
}

=item _Test()

returns Data

    my $ReturnData => $OperationObject->_Test(
        Data => { # data payload before mapping
            'abc' => 'Def,
            'ghi' => 'jkl',
        },
    );

    $ReturnData = { # data payload after mapping
            'abc' => 'Def,
            'ghi' => 'jkl',
    };

=cut

sub _Test {
    my ( $Self, %Param ) = @_;

    my $ReturnData = {};
    for my $Key ( keys %{ $Param{Data} } ) {
        $ReturnData->{$Key} = $Param{Data}->{$Key};
    }

    return $ReturnData;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

=head1 VERSION

$Revision: 1.1 $ $Date: 2011-02-10 08:45:20 $

=cut
