# Index

*   [Functionality](#funcionalidades)
*   [User Registration](#registro-de-usuario)
*   [User Profile](#perfil-de-usuario)
*   [Administrator, moderator and administrator profiles](#perfiles-de-administrador,-moderador-y-gestor)
*   [Profiles of evaluator and table chair](#perfiles-de-evaluador-y-presidente-de-mesa)

## Functionality

CONSUL currently supports:

*   Registration and verification of users both in the same application and with different providers (Twitter, Facebook, Google).
*   Different user profiles, both individual citizens and organizations and public officials.
*   Different profiles of administration, management, evaluation and moderation.
*   Permanent space for debates and proposals.
*   Comments nested in debates and proposals.
*   Participatory budgeting through different phases.

## User Registration

To register a new user it is possible to do it in the application itself, giving a username (public name that will appear in your publications), an email and a password with which the web will be accessed. The terms of use must be accepted. The user must confirm their email in order to log in.

![Registro de usuario](imgs/user_registration.png "Registro de usuario")

On the other hand, registration can also be enabled through external services such as Twitter, Facebook and Google. For this it is necessary to have the configuration enabled in Settings and the keys and secrets of these services in the file *config/secrets.yml*.

      twitter_key: ""
      twitter_secret: ""
      facebook_key: ""
      facebook_secret: ""
      google_oauth2_key: ""
      google_oauth2_secret: ""

Once the user has logged in, the possibility of verifying their account will appear, through a connection with the municipal register.

![Verificación de usuario](imgs/user_preverification.png?raw=true "Verificación de usuario")

For this functionality it is necessary that the municipal register supports the possibility of connection through an API, you can see an example in *lib/census_api.rb*.

![Verificación de usuario](imgs/user_verification.png?raw=true "Verificación de usuario")

## User Profile

Within their profile ("My Account" in the top menu) each user can configure whether they want to publicly display their list of activities, as well as the notifications that the application will send them via email. These notifications can be:

*   Receive an email when someone comments on your proposals or discussions.
*   Receive an email when someone replies to your comments.
*   Receive emails with interesting information about the web.
*   Receive summary of notifications about proposals.
*   Receive emails with private messages.

## Administrator, moderator and administrator profiles

CONSUL has three user profiles to manage web content: administrator, moderator and manager. It also has two other profiles for participatory process management: [evaluator and table chair](#perfiles_de_evaluador,\_gestor_y_presidente_de_mesa), which are detailed below.

Users with an administrator profile can assign any type of profile to any type of user. However, all profiles have to be verified users (contrasted with the municipal register) to be able to perform certain actions (for example, managers need to be verified to create spending projects).

### Manage panel

![Panel de administración](imgs/panel_administration.png?raw=true "Panel de administración")

From here you can manage the system, through the following menus:

#### Categories ![categorias](imgs/icon_categories.png?raw=true "categorías")

##### Topics for discussions/proposals

Topics (also called tags, or tags) are words that define users when creating debates or proposals to facilitate their cataloging (eg: health, mobility, arganzuela, ...). From here the administrator has the following options:

*   Create new themes
*   Remove inappropriate topics
*   Mark topics to appear as a suggestion when creating discussions/proposals. Each user can create the ones they want, but the administrator can suggest some that they find useful as default cataloging. By checking "Propose topic when creating the proposal" on each topic, set which ones are suggested.

#### Moderated content ![contenido moderado](imgs/icon_moderated_content.png?raw=true "contenido moderado")

##### Proposals/Debates/Hidden Comments

When an administrator or moderator hides a Proposal/Discussion/Comment from the web, it will appear in this list. This way administrators can review the items that have been hidden and correct possible errors.

*   By clicking "Confirm" the one that has been hidden is accepted; it is considered to have been done correctly.
*   If it is considered that the hiding has been erroneous, clicking "Show again" reverses the action of hiding and returns to be a Proposal / Debate / Comment visible on the web.

To facilitate the management, above we find a filter with the sections: "Pending" (the elements on which "Confirm" or "Reshow" have not yet been clicked, which should still be reviewed), "Confirmed" and "All".

It is advisable to regularly check the "Pending" section.

#### Blocked users

When a moderator or administrator blocks a user from the web, they appear in this list. When a user is blocked, they cannot perform actions on the web, and all their Proposals/Debates/Comments will no longer be visible.

*   By clicking "Confirm" the block is accepted; it is considered to have been done correctly.
*   If the lock is considered to have been erroneous, clicking "Show Again" reverses the lock and the user is active again.

#### Votes ![votaciones](imgs/icon_polls.png?raw=true "votaciones")

You can create a vote by clicking "Create Vote" and defining a name, opening and closing date. Additionally, voting can be restricted to certain areas by checking "Restrict by zones". The available zones are defined in the menu [Manage districts](#gestionar-distritos).

Users must be verified in order to participate in the vote.

Once the vote has been created, its components are defined and added. The votes have three components: Citizen Questions, Table Presidents and Location of the ballot boxes.

##### Citizen Questions

You can create a citizen question or search for an existing one. When creating the question it can be assigned to a certain vote. You can also modify the assignment to an existing question by pressing it and selecting "Edit".

From the Citizen Questions section, those Citizen Proposals that have exceeded the threshold of support can also be assigned to a vote. They can be selected from the "Proposals that have exceeded the threshold" tab.

##### Chairmen

Any user registered on the web can become a Table Chair. To assign him that role, his email is entered in the search field and once found it is assigned with "Add as Table President". When presidents access the web with their user they see at the top a new section called "Table Presidents".

##### Location of the ballot boxes

To add an urn to the list, select "Add Urn" and then fill in the urn name and location data.

#### Participatory budgeting ![presupuestos participativos](imgs/icon_participatory_budgeting.png?raw=true "presupuestos participativos")

From this section you can create a participatory budget by selecting "Create new budget" or edit an existing one. By editing you can change the phase in which the process is located; this change will be reflected on the web. You can also create groups of budget items and add spending projects that have been previously created by a [manager](#panel-gestión).

#### Profiles ![perfiles](imgs/icon_profiles.png?raw=true "perfiles")

##### Organizations

On the web any user can register with an individual profile or as an organization. Users of organizations can be verified by administrators, confirming that who manages the user effectively represents that organization. Once the verification process has been carried out, by the external process to the web that has been defined for it, the "Verify" button is pressed to confirm it; which will cause a label appearing next to the name of the organization indicating that it is a verified organization.

In case the verification process has been negative, the "Reject" button is pressed. To edit any of the organization's data, click the "Edit" button.

Organizations that do not appear in the list can be found to act on them through the search engine at the top. To facilitate management, above we find a filter with the sections: "pending" (organizations that have not yet been verified or rejected), "verified", "rejected" and "all".

It is advisable to regularly review the "pending" section.

##### Public Offices

The status of public office cannot be chosen in the registration that is made from the web: it is assigned directly from this section. The administrator searches for a user by entering their email in the search field and assigns them the role of Public Office.

Public office differs from the individual user only in that a label identifying him appears next to his name, and slightly changes the style of his comments. This allows users to identify you more easily. Next to each charge we see the identification that appears on its label, and its level (the way the web internally uses to differentiate between one type of charges and others). By pressing the "Edit" button next to the user, their information can be modified. Public officials who do not appear on the list can be found to act on them through the search engine at the top.

##### Moderators

Any user registered on the web can become a moderator. To assign that role, your email is entered in the search field and once found it is assigned with "Add as Moderator". When moderators access the web with their user they see at the top a new section called "Moderate".

Selecting "Moderator Activity" displays a list of all the actions that moderators perform: hide/show Proposals/Discussions/Comments and block users. In the "Action" column we check if the action corresponds to hide or to show (restore) elements or to block users. In the other columns we have the type of element, the content of the element and the moderator or administrator who has performed the action.

This section allows administrators to detect irregular behavior by specific moderators and thus be able to correct them.

##### Evaluators

Any user registered on the web can become an evaluator. To assign that role, your email is entered in the search field and once found it is assigned with "Add as evaluator". When the evaluators access the web with their user they see at the top a new section called "Evaluation".

##### Managers

Any user registered on the website can become a manager. To assign that role, your email is entered in the search field and once found it is assigned with "Add as manager". When managers access the website with their user they see at the top a new section called "Management".

#### Banners ![banners](imgs/icon_banners.png?raw=true "banners")

From the "Manage banners" menu you can create banners to make special announcements that will always appear at the top of the web, both in the discussions and proposals sections. To create it you have to select "Create banner" and enter your data and start and end dates of publication in format `dd/mm/aaa`.

By default, only one banner will appear on the web. If there are several banners whose dates indicate that they should be active, only the one whose publication start date is older will be displayed.

#### Customize site ![personalizar sitio](imgs/icon_customize_site.png?raw=true "personalizar sitio")

##### Customize pages

The pages serve to display any type of static content related to the participation processes. When creating or editing a page you must enter a *Slug* to define the *permalink* of that page in question. Once created, we can access it from the list, selecting "View page".

##### Customize images

From this panel, the images of the corporate elements of your CONSUL are defined.

##### Customize blocks

You can create HTML blocks that will be embedded in the header or footer of your CONSUL.

Header blocks (top_links) are blocks of links that must be created in this format:

    <li><a href="http://site1.com">Site 1</a></li>
    <li><a href="http://site2.com">Site 2</a></li>
    <li><a href="http://site3.com">Site 3</a></li>

Footer blocks can be in any format and can be used to save Javascript footprints, CSS content, or custom HTML content.

#### Manage districts

From this menu you can create the different districts of a municipality with their name, coordinates, external code and census code.

#### Signature sheets

In order to register external support for the platform, you can create signature sheets of Citizen Proposals or Expenditure Projects by entering the ID of the proposal in question and entering the numbers of the documents separated by commas(,).

#### Statistics

General statistics of the system.

#### Global settings

General system configuration options.

### Moderate panel

![Panel de moderación](imgs/panel_moderation.png?raw=true "Panel de moderación")

From here you can moderate the system, through the following actions:

#### Proposals / Debates / Comments

When a user marks in a Proposal/Debate/Comment the option to "report as inappropriate", it will appear in this list. Regarding each one, the title, date, number of complaints (how many different users have checked the complaint option) and the text of the Proposal/Debate/Comment will appear.

To the right of each item appears a box that we can mark to select all the ones we want from the list. Once one or more have been selected, we find at the end of the page three buttons to perform actions on them:

*   Hide: will cause those elements to stop showing on the web.
*   Block authors: it will cause the author of that element to stop being able to access the web, and that in addition all the Proposals / Debates / Comments of that user stop being shown on the web.
*   Mark as reviewed when we consider that those elements should not be moderated, that their content is correct, and that therefore they should stop being shown in this list of inappropriate elements.

To facilitate management, above we find a filter with the sections:

*   Pending: Proposals/Debates/Comments that have not yet been clicked "hide", "block" or "mark as reviewed", and that therefore should be reviewed yet.
*   All: showing all proposals/debates/comments on the website, and not just those marked as inappropriate.
*   Marked as reviewed: those that some moderator has marked as reviewed and therefore seem correct.

It is advisable to regularly review the "pending" section.

#### Block users

A search engine allows us to find any user by entering their username or email, and block it once found. By blocking it, the user will not be able to access the web again, and all their Proposals/Debates/Comments will be hidden and will no longer be visible on the web.

### Management Panel

![Panel de gestión](imgs/panel_management.png?raw=true "Panel de gestión")

From here you can manage users through the following actions:

*   Users.
*   Edit user account.
*   Create proposal.
*   Support proposals.
*   Create spending project.
*   Support spending projects.
*   Print proposals.
*   Print spending projects.
*   Invitations for users.

## Profiles of evaluator and table chair

### Evaluation Panel

### Table Chairs Panel
