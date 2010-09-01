// --
// Core.Customer.js - provides functions for the customer login
// Copyright (C) 2001-2010 OTRS AG, http://otrs.org/\n";
// --
// $Id: Core.Customer.js,v 1.9 2010-09-01 13:56:33 mg Exp $
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};

/**
 * @namespace
 * @exports TargetNS as Core.Customer
 * @description
 *      This namespace contains all form functions.
 */
Core.Customer = (function (TargetNS) {
    if (!Core.Debug.CheckDependency('Core.Customer', 'Core.UI', 'Core.UI')) {
        return;
    }
    if (!Core.Debug.CheckDependency('Core.Customer', 'Core.UI.IE7Fixes', 'Core.UI.IE7Fixes')) {
        return;
    }
    if (!Core.Debug.CheckDependency('Core.Customer', 'Core.Form', 'Core.Form')) {
        return;
    }
    if (!Core.Debug.CheckDependency('Core.Customer', 'Core.Form.Validate', 'Core.Form.Validate')) {
        return;
    }
    if (!Core.Debug.CheckDependency('Core.Customer', 'Core.UI.Accessibility', 'Core.UI.Accessibility')) {
        return;
    }

    /**
     * @function
     * @return nothing
     *      This function initializes the application and executes the needed functions
     */
    TargetNS.Init = function () {
        Core.Form.Validate.Init();
        // late execution of accessibility code
        Core.UI.Accessibility.Init();
        // init IE7 compat code (will only run on IE7)
        Core.UI.IE7Fixes.InitIE7InputFocus('Focus');
        Core.UI.IE7Fixes.InitIE7InputReadonly('Readonly');
    };

    /**
     * @function
     * @description
     *      This function makes the whole row in the MyTickets and CompanyTickets view clickable.
     */

    TargetNS.ClickableRow = function(){
        $("table tr").click(function(){
            window.location.href = $("a", this).attr("href");
        });
    };

    /**
     * @function
     * @description
     *      This function adds the class 'JavaScriptAvailable' to the 'Body' div to enhance the interface (clickable rows).
     */
    TargetNS.Enhance = function(){
        $('body').addClass('JavaScriptAvailable');
    }

    TargetNS.InitFocus = function(){
        $('input[type="text"]').first().focus();
    }

    return TargetNS;
}(Core.Customer || {}));
