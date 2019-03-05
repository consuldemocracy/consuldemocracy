# Basic Configuration

Once you have CONSUL running on the server, there are some basic configuration options that you probably want to define in order to start using it. To do this you will need to open your CONSUL installation through any internet browser and log in with the administration user (initially it is the `admin@consul.dev` user with the password `12345678`). Once you have logged in you will see on the top right of the screen the "Admin" link that will take you to the administration interface. From this interface you can configure the following basic options:

## Global configuration parameters
In the side menu you will find the option "Settings" and then the submenu "Global Settings". Here you will find many interesting parameters, but at the moment we recommend you to define some of the most basic ones. Later, when you are more familiar with the tool, you will be able to reconfigure other parameters:

- Site name. This name will appear in the subject of emails, help pages...
- Sender email name. This name will appear as the name of the sender in the emails sent from the application. As for example the email that the users receive to confirm that they have created their account.
- Sender email address. This email address will appear in the emails sent from the application.
- Main URL. Main URL of your website
- Minimum age needed to participate. If you use a user verification system this will be the minimum age that users will be required to be. The user verification system will be discussed in more detail later.
- Number of supports necessary for approval of a Proposal. If you use the citizen proposals section, you can define a minimum number of supports that the proposals need in order to be considered. Any user will be able to create proposals but only those that reach that value will be taken into account.
- Level x public official . CONSUL allows some user accounts to be marked as "official accounts" and their interventions on the platform are highlighted. This for example is used in a city if you want to define accounts for the Mayor, Councillors, etc. This public official option will allow you to define the official label that appears next to the user names of these accounts from most important (level 1) to least (level 5).

## Categories of proposals
When users create proposals on the platform, a few general categories are suggested to help organize the proposals. To define these categories you can go to the "Global Settings" menu and then to the "Proposal Topics" submenu. At the top you can write topics and create them with the button below.

## Definition of Geozones
Geozones are smaller territorial areas than the area in which you use CONSUL (e.g. districts in a city in which CONSUL is used). If the geozones are activated, it will allow for example that the citizen proposals are assigned to a specific area, or that the votings are restricted to people living in some area.

In the side menu you will find the option "Settings" and then the submenu "Manage geozones". To the right the button "Create geozone" will allow you to create new geozones. Only the name is necessary to define them, but you can add other data that are useful in certain sections. Initially we recommend that you start by defining only the names of the zones.

Once defined if you create a citizen proposal you will see how one of the options in the proposal creation form allows you to choose if your proposal refers to a specific geozone.

If you activate the geozones you can also display an image that represents the area with the zones. You can change this image in the "Global settings" menu in the "Customize images" submenu. The default image you can change is the one titled "map".

## Map to geolocate proposals
You can allow users to place proposals on a map when creating proposals. To do this you have to define which map you want to show.
First go to the "Settings" menu and to the "Global Settings" submenu. There you will find three parameters that you will have to fill in:

- Latitude. Latitude to show the map position
- Length. Length to show the map position
- Zoom. Zoom to show the position of the map. You can try an initial value and then change it later.

At the top of this page you will find three tabs: "Configuration settings", "Features", "Map configuration". Now go to the second tab "Features".

On this page you will find one of the functionalities titled "Proposals and budget investments geolocation ". The message "Functionality enabled" should appear on your right. If not, click on the "Enable" button.

Then, at the top of this page, go to the "Map configuration" tab. If everything has been configured correctly you will see here the map centered on the latitude and longitude you entered before. You can correctly center the map and change the zoom level directly on the map by clicking on the "Update" button below it.

## Emails to users
CONSUL sends a series of emails to users by default. For example when creating a user account, trying to recover a password, receiving a message from another user, etc.

All emails sent can be viewed in the menu "Messages to users" in the submenu "System Emails". There you will be able to preview each email and see the file where the content of the email is in case you want to change it.

## Basic information pages
CONSUL has a number of basic information pages that will be shown to users, e.g. "Privacy Policy", "Frequently Asked Questions", "Congratulations you have just created your user account", etc.

You can see the pages that exist by default and modify them in the menu "Site Content" in the submenu "Custom Pages".

## Main page of the site
When users open your CONSUL installation they will see the home page of the platform. This page is fully configurable, so that you can show the content that seems most relevant to you. You can modify it from the menu "Site content" in the submenu "Homepage".

Try creating "Headers" and "Cards" and activating the different functionalities you will find below to see the effect they have on your homepage.

## Platform texts
If you access the menu "Site content" and the submenu "Custom information texts" you will see different tabs with a series of texts. These are all the texts displayed on the platform. By default you can use the existing ones, but at any time you can access this section to modify any of the texts.

For more information on how to add new translations to your version of CONSUL access the "Texts and translations" section of this documentation.

## Channels of participation
By default you will find in CONSUL different ways of participation for users. To begin with and familiarise yourself with the tool, we recommend that you have all of them activated, but you can deactivate the ones that do not seem necessary to you. To do this, go to the "Settings" menu and then to the "Global Settings" submenu. At the top of this page you will find three tabs: "Configuration settings", "Features", "Map configuration". Go to the second tab "Features".

You will find different functionalities with the names of the different participation channels "Debates", "Proposals", "Voting", "Collaborative Legislation" and "Participatory Budgets". You can deactivate any of the functionalities and it will no longer be shown in your CONSUL installation.

### More information and detailed documentation
These options above will allow you to have a basic version of CONSUL to start using. We recommend that you access the [CONSUL Documentation and Guides](../getting_started/documentation_and_guides.md) section where you can find more detailed documentation.
