# Basic configuration

Once you have Consul Democracy running on the server, there are some basic configuration options that you probably want to define in order to start using it.

To do this, you will need to go to your Consul Democracy installation URL with any browser and log in with the administration user (initially it is the `admin@consul.dev` user with the password `12345678`).

Once you have logged in you will see on the top right of the screen a "Menu" button. Click on it and then click on "Administration" to go to the administration area. From this interface you can configure the following basic options:

## Change the administrator credentials

Since the `admin@consul.dev` email address doesn't exist, and since anyone familiar with Consul Democracy will know the default password, we strongly recommended that you change the login credentials immediately after installing the application.

First, sign in using the default administrator credentials.

Then, click on "My account". On the "My account" page, click on "Change my login details". Fill in the form with the new email and password.

The password will be updated immediately, and you can sign out and sign in using the new password. In order to update the email address, you will receive an email on that address asking to confirm your account. Click on the link included in that email, and you'll be able to sign in using the new email address.

You can also change the default "admin" username. Once again, go to "My account". On that page, you will see a form containing a "username" field. Just change the username and click on the form button to update it.

It's possible that, before following this process, you've already signed up with the email you'd like to use as an administrator. If that's the case, instead of following the previous process, sign in as an administrator and go the admin area. Once there, on the side navigation menu, click on "Profiles" to open a submenu and then click on "Administrators". To add an administrator, use the search form and enter the email of the user you'd like to make an administrator (not very intuitive; sorry for that!). Once the search results are returned, click on the "Add" icon. Now, sign out, sign in as the new administrator, go to the admin area, click once again on "Profiles" and then on "Administrators" and delete the default `admin@consul.dev` administrator. Note that this won't delete the user, but that user will no longer be an administrator.

## Global configuration parameters

In the admin area, on the side navigation menu, click on "Settings" to open a submenu and then click on "Global settings". Here you will find many interesting parameters, but at the moment we recommend you to define some of the most basic ones (later, when you are more familiar with the tool, you will be able to configure other parameters):

* Site name. This name will appear in the subject of emails, help pages, ...
* Sender email name. This name will appear as the name of the sender in the emails sent from the application. For example, the email that users receive to confirm that they have created their account.
* Sender email address. This email address will appear in the emails sent from the application.
* Minimum age needed to participate. If you use a user verification system, this will be the minimum age that users will be required to be.
* Number of supports necessary for approval of a Proposal. If you use the citizen proposals section, you can define a minimum number of supports that the proposals need in order to be considered. Any user will be able to create proposals but only those that reach that value will be taken into account.
* Level x public official. Consul Democracy allows some user accounts to be marked as "official accounts", and their interventions on the platform will be highlighted. This is used, for example, in a city, if you want to define accounts for the Mayor, Councillors, etc. This public official option will allow you to define the official label that appears next to the usernames of these accounts from most important \(level 1\) to least important \(level 5\).

## Categories of proposals

When users create proposals on the platform, a few general categories are suggested to help organize the proposals. To define these categories, on the side navigation menu you can click on "Settings" and then click on "Proposals topics". At the top you can find a form where you can write the name of a topic and create it with the button below it.

## Definition of geozones

Geozones are smaller territorial areas than the area in which you use Consul Democracy \(e.g. districts in a city in which Consul Democracy is used\). If the geozones are activated, it will allow for example that citizen proposals are assigned to a specific area, or that polls are restricted to people living in some area.

On the side navigation menu, click on "Settings" and then click on "Geozones". The "Create geozone" button on the right will allow you to create new geozones. Only the name is necessary to define them, but you can add other data which might be useful in certain sections. Initially we recommend that you start by defining only the names of the zones.

Once defined, if you create a citizen proposal you will see how one of the options in the proposal creation form allows you to choose if your proposal refers to a specific geozone.

If you activate the geozones, you can also display an image that represents the area with the zones. You can change this image by clicking on "Site content" (on the side navigation menu) and then clicking on "Custom images". The default image you can change is the one titled "map".

## Map to geolocate proposals

You can allow users to place proposals on a map when creating proposals. To do this, you have to define which map you'd like to show.

First, on the side navigation menu click on "Settings" and then click on "Global settings". At the top of this page you'll find a few tabs. Click on the "Features" tab.

On this page, look for a feature titled "Proposals and budget investments geolocation ". If it isn't already enabled, enable it.

Then, at the top of this page, go to the "Map configuration" tab. There you will find three parameters that you will have to fill in:

* Latitude. Latitude to show the map position.
* Longitude. Longitude to show the map position.
* Zoom. Zoom to show the position of the map. You can try an initial value and then change it later.

Then, click on the "Update" button.

If everything has been configured correctly, you will see the map centered on the latitude and longitude you entered before. You can also center the map and change the zoom level directly on the map and then click on the "Update" button.

## Emails to users

Consul Democracy sends a series of emails to users. For example, when creating a user account, trying to recover a password, receiving a message from another user, etc.

You can check the content of the templates of the emails that Consul Democracy sends by clicking on "Messages to users" (on the side navigation menu) and then clicking on "System Emails". There you'll be able to preview each email and see a filename indicating where the content of the email is in case you'd like to [customize it](../customization/customization.md).

## Basic information pages

By default, Consul Democracy includes some basic information pages that will be shown to users, e.g. "Privacy Policy", "Frequently Asked Questions", "Congratulations you have just created your user account", etc.

You can modify these pages and add new ones by clicking on "Site content" (on the side navigation menu) and then clicking on "Custom pages".

## Homepage

When users access your Consul Democracy installation, they will see the homepage. This page is configurable, so that you can show the content that seems most relevant to you. You can modify it by clicking on "Site content" (on the side navigation menu) and then clicking on "Homepage".

Try creating "Headers" and "Cards" and activating/deactivating the different functionalities you will find below them to check the effect they have on your homepage.

## Platform texts

If, on the side navigation menu, you click on "Site content" and then on "Custom information texts", you will see different tabs with a series of texts. These are all the texts displayed on the platform. By default, you can use the existing ones, but at any time you can access this section to modify any of the texts.

For more information on how to add new translations to your version of Consul Democracy, check the ["Texts and translations"](../customization/translations.md) section of this documentation.

## Types of participation processes

By default, in Consul Democracy users can participate in different ways. In order to get familiar with the tool, we recommend that you activate them all, but you can deactivate the ones that you don't need. To do this, on the side navigation menu click on "Settings" and then click on "Global settings". At the top of this page you will find a few tabs. Click on the "Participation processes" tab.

You will find different functionalities with the names of the different types of participation processes: "Debates", "Proposals", "Voting", "Collaborative legislation" and "Participatory budgets". You can deactivate any of these functionalities and it will no longer be shown in your Consul Democracy installation.

## More information and detailed documentation

The options above will allow you to configure your initial version of Consul Democracy. We recommend that you check the [User documentation and guides](documentation_and_guides.md) section, where you can find links to more detailed documentation.
