# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html)

## [1.2.0](https://github.com/consul/consul/tree/1.2.0) (2020-09-25)

[Full Changelog](https://github.com/consul/consul/compare/1.1.0...1.2.0)

### Added

- **Admin:** Filter erased users and show erase reason in admin [\#3980](https://github.com/consul/consul/pull/3980)
- **Admin:** Add title to differentiate signature sheets [\#3940](https://github.com/consul/consul/pull/3940)
- **Budgets:** Add approval voting to budgets [\#4062](https://github.com/consul/consul/pull/4062) and [\#4063](https://github.com/consul/consul/pull/4063)
- **Bugs:** Add support for Errbit self-hosted exception management [\#3624](https://github.com/consul/consul/pull/3624) and [\#4129](https://github.com/consul/consul/pull/4129)
- **Design/UX:** Allow to paste formatted content into ckeditors [\#3979](https://github.com/consul/consul/pull/3979)
- **Legislation:** Add collaborative legislation summary [\#4065](https://github.com/consul/consul/pull/4065)
- **Translations:** Add Serbian (Cyrillic) new language mapping [\#4130](https://github.com/consul/consul/pull/4130)
- **Translations:** Update translations from Crowdin [\#4121](https://github.com/consul/consul/pull/4121) and [\#4140](https://github.com/consul/consul/pull/4140)

### Changed

- **Admin:** Clarify the meaning of max "votable" headings [\#4126](https://github.com/consul/consul/pull/4126)
- **Admin:** Filter investments only by assigned staff [\#4125](https://github.com/consul/consul/pull/4125)
- **Admin:** Allow admins to hide proposals created by themselves [\#3884](https://github.com/consul/consul/pull/3884)
- **Design/UX:** Use native HTML5 date fields in the admin section [\#4111](https://github.com/consul/consul/pull/4111) and [\#4112](https://github.com/consul/consul/pull/4112)
- **Design/UX:** Don't use confirm dialog in admin homepage form [\#4023](https://github.com/consul/consul/pull/4023)
- **Design/UX:** Replaces icons of expand/collapse comments [\#3972](https://github.com/consul/consul/pull/3972)
- **Design/UX:** Don't count errors for the same field twice [\#3768](https://github.com/consul/consul/pull/3768)
- **Documentation:** Update contributing [\#3990](https://github.com/consul/consul/pull/3990)
- **Maintenance**: Remove deprecated columns [\#4116](https://github.com/consul/consul/pull/4116)
- **Maintenance**: Remove Google plus share button [\#4064](https://github.com/consul/consul/pull/4064)
- **Maintenance:** Upgrade to jQuery 3.5.1 [\#4051](https://github.com/consul/consul/pull/4051)
- **Maintenance:** Remove unused document section on polls [\#4046](https://github.com/consul/consul/pull/4046)
- **Maintenance:** Add Rails 5.2 compatibility [\#4028](https://github.com/consul/consul/pull/4028)
- **Maintenance:** Use a memory cache store in development [\#4007](https://github.com/consul/consul/pull/4007)
- **Maintenance:** Remove unused tag filter [\#3966](https://github.com/consul/consul/pull/3966)
- **Maintenance-Deployment:** Upgrade Ruby to 2.5.8 [\#3978](https://github.com/consul/consul/pull/3978) and [\#4127](https://github.com/consul/consul/pull/4127)
- **Maintenance-Docker:** Update ruby version docker [\#3960](https://github.com/consul/consul/pull/3960)
- **Maintenance-Gems:** Bump omniauth-facebook from 4.0.0 to 7.0.0 [\#4107](https://github.com/consul/consul/pull/4107)
- **Maintenance-Gems:** Bump database_cleaner from 1.7.0 to 1.8.5 [\#4100](https://github.com/consul/consul/pull/4100)
- **Maintenance-Gems:** Bump font-awesome-sass from 5.8.1 to 5.13.0 [\#4095](https://github.com/consul/consul/pull/4095) and [\#4097](https://github.com/consul/consul/pull/4097)
- **Maintenance-Gems:** Bump i18n-tasks from 0.9.29 to 0.9.31 [\#4094](https://github.com/consul/consul/pull/4094)
- **Maintenance-Gems:** Bump scss_lint from 0.55.0 to 0.59.0 [\#4093](https://github.com/consul/consul/pull/4093)
- **Maintenance-Gems:** Bump capistrano-rails from 1.4.0 to 1.6.1 [\#4092](https://github.com/consul/consul/pull/4092)
- **Maintenance-Gems:** Bump capybara-webmock from 0.5.3 to 0.5.5 [\#4091](https://github.com/consul/consul/pull/4091)
- **Maintenance-Gems:** Bump initialjs-rails from 0.2.0.8 to 0.2.0.9 [\#4090](https://github.com/consul/consul/pull/4090)
- **Maintenance-Gems:** Bump web-console from 3.3.0 to 3.7.0 [\#4088](https://github.com/consul/consul/pull/4088)
- **Maintenance-Gems:** Bump omniauth-google-oauth2 from 0.4.1 to 0.8.0 [\#4084](https://github.com/consul/consul/pull/4084)
- **Maintenance-Gems:** Bump mdl from 0.5.0 to 0.11.0 [\#4078](https://github.com/consul/consul/pull/4078) and [\#4103](https://github.com/consul/consul/pull/4103)
- **Maintenance-Gems:** Bump groupdate from 3.2.0 to 5.1.0 [\#4075](https://github.com/consul/consul/pull/4075)
- **Maintenance-Gems:** Bump rollbar from 2.18.0 to 2.27.0 [\#4069](https://github.com/consul/consul/pull/4069)
- **Maintenance-Gems:** Bump wicked_pdf from 1.1.0 to 2.1.0 [\#4044](https://github.com/consul/consul/pull/4044)
- **Maintenance-Gems:** \[Security\] Bump rack from 2.2.2 to 2.2.3 [\#4042](https://github.com/consul/consul/pull/4042)
- **Maintenance-Gems:** \[Security\] Bump geocoder from 1.4.5 to 1.6.3 [\#4035](https://github.com/consul/consul/pull/4035)
- **Maintenance-Gems:** \[Security\] Bump websocket-extensions from 0.1.4 to 0.1.5 [\#4033](https://github.com/consul/consul/pull/4033)
- **Maintenance-Gems:** \[Security\] Bump kaminari from 1.1.1 to 1.2.1 [\#4027](https://github.com/consul/consul/pull/4027)
- **Maintenance-Gems:** \[Security\] Bump puma from 4.3.3 to 4.3.5 [\#4014](https://github.com/consul/consul/pull/4014)
- **Maintenance-Gems:** \[Security\] Bump json from 2.1.0 to 2.3.0 [\#3951](https://github.com/consul/consul/pull/3951)
- **Maintenance-Gems:** Bump omniauth from 1.9.0 to 1.9.1 [\#3935](https://github.com/consul/consul/pull/3935)
- **Maintenance-Gems:** Bump paperclip from 5.2.1 to 6.1.0 [\#3905](https://github.com/consul/consul/pull/3905) and [\#4115](https://github.com/consul/consul/pull/4115)
- **Maintenance-Gems:** Bump acts-as-taggable-on from 6.0.0 to 6.5.0 [\#3865](https://github.com/consul/consul/pull/3865)
- **Maintenance-Gems:** Bump capybara from 2.17.0 to 3.29.0 [\#3788](https://github.com/consul/consul/pull/3788)
- **Maintenance-Gems:** Bump jquery-fileupload-rails from 0.4.7 to 1.0.0 [\#3710](https://github.com/consul/consul/pull/3710)
- **Maintenance-Gems:** Bump cocoon from 1.2.11 to 1.2.14 [\#3708](https://github.com/consul/consul/pull/3708)
- **Maintenance-Gems:** Bump turbolinks to 5.2.1 [\#3699](https://github.com/consul/consul/pull/3699) and [\#4114](https://github.com/consul/consul/pull/4114)
- **Maintenance-Gems:** Bump daemons and capistrano3-delayed-job [\#3665](https://github.com/consul/consul/pull/3665)
- **Maintenance-Gems:** Bump rails-assets-markdown-it from 8.2.2 to 9.0.1 [\#3662](https://github.com/consul/consul/pull/3662)
- **Maintenance-Gems:** Upgrade to Rails 5.1 [\#3621](https://github.com/consul/consul/pull/3621) and [\#3633](https://github.com/consul/consul/pull/3633)
- **Maintenance-Gems:** Bump rails-assets-leaflet from 1.2.0 to 1.5.1 [\#3605](https://github.com/consul/consul/pull/3605)
- **Maintenance-Refactoring:** Apply Legislation Process default colors to dev seeds [\#4117](https://github.com/consul/consul/pull/4117)
- **Maintenance-Refactoring:** Use complete keys on legislation translations [\#4076](https://github.com/consul/consul/pull/4076)
- **Maintenance-Refactoring:** Simplify Javascript code [\#4073](https://github.com/consul/consul/pull/4073)
- **Maintenance-Refactoring:** Remove redundant calls to load resources [\#4070](https://github.com/consul/consul/pull/4070)
- **Maintenance-Refactoring:** Rename admin proposal notifications controller [\#4040](https://github.com/consul/consul/pull/4040)
- **Maintenance-Refactoring:** Move conditional into shared banner partial [\#4004](https://github.com/consul/consul/pull/4004)
- **Maintenance-Rubocop:** Apply Layout/SpaceAroundMethodCallOperator rule [\#4036](https://github.com/consul/consul/pull/4036)
- **Maintenance-Rubocop:** Increase severity of DynamicFindBy rubocop rule [\#3985](https://github.com/consul/consul/pull/3985)
- **Maintenance-Specs:** Fix chromedriver hanging with CKEditor [\#4026](https://github.com/consul/consul/pull/4026)
- **Maintenance-Specs:** Simplify chromedriver installation with webdrivers [\#4012](https://github.com/consul/consul/pull/4012)
- **Maintenance-Specs:** Fix flaky nested documentable / imageable specs [\#4010](https://github.com/consul/consul/pull/4010)
- **Maintenance-Specs:** Mitigate flaky specs for vote multiple times [\#3982](https://github.com/consul/consul/pull/3982)
- **Maintenance-Specs:** Fix checking for nil in page content [\#3975](https://github.com/consul/consul/pull/3975)
- **Maintenance-Specs:** Don't include unneeded helpers in tests [\#3974](https://github.com/consul/consul/pull/3974)
- **Maintenance-Specs:** Fix flaky spec: Admin Active polls Add [\#3968](https://github.com/consul/consul/pull/3968)
- **Proposals:** Support creates follow [\#3895](https://github.com/consul/consul/pull/3895)
- **Translations:** Check remote translations locales at runtime [\#3992](https://github.com/consul/consul/pull/3992)
- **Security**: Apply escape\_javascript security patch [\#3963](https://github.com/consul/consul/pull/3963)

### Fixed

- **Admin:** Don't disable button to download emails [\#4083](https://github.com/consul/consul/pull/4083)
- **Admin:** Disable phase date fields when a phase is disabled [\#4082](https://github.com/consul/consul/pull/4082)
- **Admin:** Do not delete users when deleting legislation answers [\#4068](https://github.com/consul/consul/pull/4068)
- **Admin:** Allow deleting polls with answers including videos [\#4054](https://github.com/consul/consul/pull/4054)
- **Admin:** Fix deleting searched managers/moderators/admins [\#4038](https://github.com/consul/consul/pull/4038)
- **Admin:** Make the admin menu fill the screen vertically [\#4005](https://github.com/consul/consul/pull/4005) and [\#4006](https://github.com/consul/consul/pull/4006)
- **Admin:** Fix minor design details in admin front [\#3956](https://github.com/consul/consul/pull/3956)
- **Budgets:** Fix duplicate records in investments by tag [\#3967](https://github.com/consul/consul/pull/3967)
- **Dashboard:** Fix dashboard poster intro text [\#4122](https://github.com/consul/consul/pull/4122)
- **Design/UX:** Fix sticky element on medium/large screens [\#4096](https://github.com/consul/consul/pull/4096)
- **Design/UX:** Fix invalid "hint" attribute in forms [\#4087](https://github.com/consul/consul/pull/4087)
- **Design/UX:** Fix banner overlapping with other content [\#4080](https://github.com/consul/consul/pull/4080)
- **Design/UX:** Fix poll answer images not being displayed [\#4077](https://github.com/consul/consul/pull/4077)
- **Design/UX:** Add processes feature info section in the help page [\#4034](https://github.com/consul/consul/pull/4034)
- **Design/UX:** Update comment responses count when adding replies [\#4003](https://github.com/consul/consul/pull/4003) and [\#4008](https://github.com/consul/consul/pull/4008)
- **Design/UX:** Destroy and intialize ckeditor on browser history back [\#3998](https://github.com/consul/consul/pull/3998)
- **Design/UX:** Do not run all javascript after every ajax call [\#3997](https://github.com/consul/consul/pull/3997)
- **Design/UX:** Do not update form location fields when marker is not defined [\#3995](https://github.com/consul/consul/pull/3995)
- **Design/UX:** Add ckeditor tabletools plugin [\#3983](https://github.com/consul/consul/pull/3983)
- **Design/UX:** Disable ckeditor unused plugins [\#3981](https://github.com/consul/consul/pull/3981)
- **Design/UX:** Fix attaching images in CKEditor via drag and drop [\#3977](https://github.com/consul/consul/pull/3977)
- **Design/UX:** Deactivate ckeditor file attachments feature [\#3976](https://github.com/consul/consul/pull/3976)
- **Design/UX:** Replace equalizer to display flex on cards [\#3973](https://github.com/consul/consul/pull/3973)
- **Legislation:** Allow links and images on legislation drafts [\#4067](https://github.com/consul/consul/pull/4067)
- **Legislation:** Order legislation process tags alphabetically [\#3969](https://github.com/consul/consul/pull/3969)
- **Legislation:** Fix bug flagging legislation proposals [\#3948](https://github.com/consul/consul/pull/3948) and [\#3952](https://github.com/consul/consul/pull/3952)
- **Management:** Fix crash in management with successful proposals [\#4138](https://github.com/consul/consul/pull/4138)
- **Polls:** Add feature flag exception for the module polls [\#4081](https://github.com/consul/consul/pull/4081)
- **Polls:** Allow voting when skip verification is enabled [\#4047](https://github.com/consul/consul/pull/4047)
- **Proposals:** Fix a bug where a category can't be created if it already exists as a tag [\#3477](https://github.com/consul/consul/pull/3477)
- **Security:** Fix race condition with ballot lines [\#4061](https://github.com/consul/consul/pull/4061)
- **Social-Share:** Show Wordpress login button if it's the only one enabled [\#4066](https://github.com/consul/consul/pull/4066)
- **Translations:** Discard session\[:locale\] when is not valid [\#4001](https://github.com/consul/consul/pull/4001)
- **Translations:** Fix source translations [\#3987](https://github.com/consul/consul/pull/3987)
- **Translations:** Fix custom translations with options [\#3959](https://github.com/consul/consul/pull/3959)
- **Translations:** Get search dictionary based on I18n.default\_locale [\#3856](https://github.com/consul/consul/pull/3856) and [\#4050](https://github.com/consul/consul/pull/4050)
- **Verification:** Fix redirect with GET params of after POST requests [\#4079](https://github.com/consul/consul/pull/4079)

## [1.1.0](https://github.com/consul/consul/tree/1.1.0) (2020-03-11)

[Full Changelog](https://github.com/consul/consul/compare/1.0.0...1.1.0)

### Added

- **Admin:** Display preview on admin and valuators investment page [\#3427](https://github.com/consul/consul/pull/3427)
- **Admin:** Manage valuator permissions to comment and edit dossiers [\#3437](https://github.com/consul/consul/pull/3437) and [\#3817](https://github.com/consul/consul/pull/3817)
- **Admin:** Add columns selector to budget investments index [\#3439](https://github.com/consul/consul/pull/3439) and [\#3816](https://github.com/consul/consul/pull/3816) and [\#3661](https://github.com/consul/consul/pull/3661)
- **Admin:** Add change log in investment participatory budget [\#3456](https://github.com/consul/consul/pull/3456), [\#3811](https://github.com/consul/consul/pull/3811) and [\#3904](https://github.com/consul/consul/pull/3904)
- **Admin:** Add historic fields to participatory budget [\#3514](https://github.com/consul/consul/pull/3514), [\#3807](https://github.com/consul/consul/pull/3807), [\#3809](https://github.com/consul/consul/pull/3809) and [\#3919](https://github.com/consul/consul/pull/3919)
- **Admin:** Add search form on admin booths [\#3693](https://github.com/consul/consul/pull/3693) and [\#3744](https://github.com/consul/consul/pull/3744)
- **Admin:** Manage remote and local census from the admin interface [\#3646](https://github.com/consul/consul/pull/3646), [\#3773](https://github.com/consul/consul/pull/3773), [\#3775](https://github.com/consul/consul/pull/3775) and [\#3784](https://github.com/consul/consul/pull/3784)
- **Budgets:** Add tags to milestones [\#3419](https://github.com/consul/consul/pull/3419)
- **Budgets:** Add original heading id to investments [\#3597](https://github.com/consul/consul/pull/3597)
- **Budgets:** Allow users to edit investments in accepting phase [\#3716](https://github.com/consul/consul/pull/3716) and [\#3912](https://github.com/consul/consul/pull/3912)
- **Budgets:** Add timestamps to budget headings and groups [\#3783](https://github.com/consul/consul/pull/3783)
- **Dashboard:** Add related content section on proposal dashboard [\#3613](https://github.com/consul/consul/pull/3613)
- **Documentation:** Add Knapsack Pro badge [\#3894](https://github.com/consul/consul/pull/3894)
- **GraphQL:** Add setting to enable/disable api [\#2151](https://github.com/consul/consul/pull/2151)
- **Moderation:** Moderate legislation proposals [\#3602](https://github.com/consul/consul/pull/3602)
- **Social-Share:** Enable Wordpress Oauth login and registration [\#3902](https://github.com/consul/consul/pull/3902)
- **Translations:** Translate user generated content [\#3359](https://github.com/consul/consul/pull/3359), [\#3700](https://github.com/consul/consul/pull/3700), [\#3914](https://github.com/consul/consul/pull/3914) and [\#3917](https://github.com/consul/consul/pull/3917)
- **Translations:** Responsive translation interface [\#3579](https://github.com/consul/consul/pull/3579)
- **Translations:** Update translations from Crowdin [\#3883](https://github.com/consul/consul/pull/3883), [\#3887](https://github.com/consul/consul/pull/3887) and [\#3942](https://github.com/consul/consul/pull/3942)
- **Translations:** Add locales to datepicker [\#3922](https://github.com/consul/consul/pull/3922)
- **UX/UI:** Add Font Awesome icons [\#3606](https://github.com/consul/consul/pull/3606)

### Changed

- **Admin:** Remove old system recounts in the admin section [\#3608](https://github.com/consul/consul/pull/3608)
- **Documentation:** Update README link to PRs welcome [\#3697](https://github.com/consul/consul/pull/3697)
- **Documentation:** Update contributing guidelines [\#3823](https://github.com/consul/consul/pull/3823)
- **Maintenance:** Upgrade Ruby version in Dockerfile [\#3425](https://github.com/consul/consul/pull/3425)
- **Maintenance:** Use Rails 5.1 conventions in migrations and specs [\#3620](https://github.com/consul/consul/pull/3620)
- **Maintenance:** Migrate CoffeeScript to JavaScript [\#3651](https://github.com/consul/consul/pull/3651), [\#3652](https://github.com/consul/consul/pull/3652), [\#3653](https://github.com/consul/consul/pull/3653), [\#3654](https://github.com/consul/consul/pull/3654) and [\#3910](https://github.com/consul/consul/pull/3910)
- **Maintenance:** Make it easier to release a new version of CONSUL [\#3866](https://github.com/consul/consul/pull/3866)
- **Maintenance-Deployment:** Add missing subtasks to upgrade task [\#3611](https://github.com/consul/consul/pull/3611)
- **Maintenance-Deployment:** Upgrade Ruby to 2.4.9 [\#3627](https://github.com/consul/consul/pull/3627), [\#3785](https://github.com/consul/consul/pull/3785) and [\#3857](https://github.com/consul/consul/pull/3857)
- **Maintenance-Deployment:** Use puma instead of unicorn [\#3694](https://github.com/consul/consul/pull/3694), [\#3705](https://github.com/consul/consul/pull/3705), [\#3849](https://github.com/consul/consul/pull/3849), [\#3850](https://github.com/consul/consul/pull/3850), [\#3876](https://github.com/consul/consul/pull/3876) and [\#3934](https://github.com/consul/consul/pull/3934)
- **Maintenance-Deployment:** Define SMTP settings in secrets file [\#3695](https://github.com/consul/consul/pull/3695/), [\#3853](https://github.com/consul/consul/pull/3853), [\#3870](https://github.com/consul/consul/pull/3870) and [\#3871](https://github.com/consul/consul/pull/3871)
- **Maintenance-Deployment:** Restart the application on every reboot [\#3859](https://github.com/consul/consul/pull/3859)
- **Maintenance-Deployment:** Specify which bundler version to install [\#3931](https://github.com/consul/consul/pull/3931)
- **Maintenance-Deployment:** Allow deploying a specific branch to production [\#3938](https://github.com/consul/consul/pull/3938)
- **Maintenance-Gems:** Bump email_spec from 2.1.1 to 2.2.0 [\#3001](https://github.com/consul/consul/pull/3001)
- **Maintenance-Gems:** Replace sass-rails gem by sassc-rails [\#3286](https://github.com/consul/consul/pull/3286)
- **Maintenance-Gems:** Bump i18n-tasks from 0.9.25 to 0.9.29 [\#3442](https://github.com/consul/consul/pull/3442)
- **Maintenance-Gems:** Bump foundation_rails_helper from 2.0.0 to 3.0.0 [\#3666](https://github.com/consul/consul/pull/3666)
- **Maintenance-Gems:** Bump paranoia from 2.4.1 to 2.4.2 [\#3667](https://github.com/consul/consul/pull/3667)
- **Maintenance-Gems:** Bump nokogiri from 1.10.2 to 1.10.8 [\#3675](https://github.com/consul/consul/pull/3675), [\#3858](https://github.com/consul/consul/pull/3858) and [\#3927](https://github.com/consul/consul/pull/3927)
- **Maintenance-Gems:** Bump devise from 4.6.2 to 4.7.1 [\#3690](https://github.com/consul/consul/pull/3690)
- **Maintenance-Gems:** Bump rubocop-rspec from 1.33.0 to 1.35.0 [\#3706](https://github.com/consul/consul/pull/3706)
- **Maintenance-Gems:** Bump ancestry from 3.0.2 to 3.0.7 [\#3707](https://github.com/consul/consul/pull/3707)
- **Maintenance-Gems:** Bump rubyzip from 1.2.2 to 1.3.0 [\#3737](https://github.com/consul/consul/pull/3737)
- **Maintenance-Gems:** Bump rubocop from 0.60.0 to 0.75.0 [\#3739](https://github.com/consul/consul/pull/3739)
- **Maintenance-Gems:** Bump loofah from 2.3.0 to 2.3.1 [\#3793](https://github.com/consul/consul/pull/3793)
- **Maintenance-Gems:** Bump ckeditor from 4.2.4 to 4.3.0 [\#3804](https://github.com/consul/consul/pull/3804) and [\#3901](https://github.com/consul/consul/pull/3901)
- **Maintenance-Gems:** Bump sitemap\_generator from 6.0.1 to 6.0.2 [\#3848](https://github.com/consul/consul/pull/3848)
- **Maintenance-Gems:** Remove browser gem direct dependency [\#3860](https://github.com/consul/consul/pull/3860)
- **Maintenance-Gems:** Bump foundation-rails from 6.4.3.0 to 6.6.1.0 [\#3886](https://github.com/consul/consul/pull/3886)
- **Maintenance-Gems:** Bump knapsack_pro from 1.1.0 to 1.15.0 [\#3873](https://github.com/consul/consul/pull/3873)
- **Maintenance-Gems:** Bump rack from 2.0.7 to 2.1.1 [\#3890](https://github.com/consul/consul/pull/3890)
- **Maintenance-Gems:** Bump user_agent_parser from 2.4.1 to 2.6.0 [\#3943](https://github.com/consul/consul/pull/3943)
- **Maintenance-Refactoring:** Refactor embed video helper to disconnect from @proposal [\#3496](https://github.com/consul/consul/pull/3496)
- **Maintenance-Refactoring:** Simplify calls to render partial [\#3628](https://github.com/consul/consul/pull/3628)
- **Maintenance-Refactoring:** Remove unnecessary code [\#3630](https://github.com/consul/consul/pull/3630), [\#3717](https://github.com/consul/consul/pull/3717), [\#3719](https://github.com/consul/consul/pull/3719) and [\#3843](https://github.com/consul/consul/pull/3843)
- **Maintenance-Refactoring:** Remove code specific to Internet Explorer 8 [\#3649](https://github.com/consul/consul/pull/3649)
- **Maintenance-Refactoring:** Remove duplicate translation classes [\#3674](https://github.com/consul/consul/pull/3674)
- **Maintenance-Refactoring:** Extract partials to show "sign in to vote" message [\#3741](https://github.com/consul/consul/pull/3741) and [\#3750](https://github.com/consul/consul/pull/3750)
- **Maintenance-Refactoring:** Simplify generating form fields with labels [\#3745](https://github.com/consul/consul/pull/3745)
- **Maintenance-Refactoring:** Use active record translations for labels [\#3746](https://github.com/consul/consul/pull/3746)
- **Maintenance-Refactoring:** Use relative URLs where possible [\#3766](https://github.com/consul/consul/pull/3766)
- **Maintenance-Refactoring:** Use the shared partial to render errors [\#3801](https://github.com/consul/consul/pull/3801)
- **Maintenance-Refactoring:** Update deprecated jQuery syntax [\#3826](https://github.com/consul/consul/pull/3826)
- **Maintenance-Refactoring:** Fix random title with trailing spaces [\#3831](https://github.com/consul/consul/pull/3831)
- **Maintenance-Rubocop:** Use Date.current and Time.current [\#3618](https://github.com/consul/consul/pull/3618)
- **Maintenance-Rubocop:** Apply Rubocop rules [\#3629](https://github.com/consul/consul/pull/3629), [\#3636](https://github.com/consul/consul/pull/3636), [\#3637](https://github.com/consul/consul/pull/3637), [\#3715](https://github.com/consul/consul/pull/3715), [\#3736](https://github.com/consul/consul/pull/3736), [\#3764](https://github.com/consul/consul/pull/3764), [\#3780](https://github.com/consul/consul/pull/3780), [\#3792](https://github.com/consul/consul/pull/3792), [\#3796](https://github.com/consul/consul/pull/3796), [\#3798](https://github.com/consul/consul/pull/3798) and [\#3834](https://github.com/consul/consul/pull/3834)
- **Maintenance-Rubocop:** Add rubocop spacing rules [\#3631](https://github.com/consul/consul/pull/3631) and [\#3795](https://github.com/consul/consul/pull/3795)
- **Maintenance-Rubocop:** Remove useless assignments [\#3724](https://github.com/consul/consul/pull/3724) and [\#3734](https://github.com/consul/consul/pull/3734)
- **Maintenance-Rubocop:** Add rubocop lint rules [\#3735](https://github.com/consul/consul/pull/3735)
- **Maintenance-Rubocop:** Remove duplicate rubocop rule [\#3789](https://github.com/consul/consul/pull/3789)
- **Maintenance-Rubocop:** Use rubocop 0.74 with code climate [\#3790](https://github.com/consul/consul/pull/3790)
- **Maintenance-Rubocop:** Merge basic and standard rubocop files in one file [\#3799](https://github.com/consul/consul/pull/3799)
- **Maintenance-Rubocop:** Add rubocop style rules [\#3803](https://github.com/consul/consul/pull/3803)
- **Maintenance-Rubocop:** Enable Lint/SafeNavigationChain rubocop rule [\#3825](https://github.com/consul/consul/pull/3825)
- **Maintenance-Seeds:** Make WebSection seeds idempotent [\#3658](https://github.com/consul/consul/pull/3658)
- **Maintenance-Specs:** Add tests for related content score [\#2214](https://github.com/consul/consul/pull/2214)
- **Maintenance-Specs:** Use one more node in the Travis matrix [\#3614](https://github.com/consul/consul/pull/3614)
- **Maintenance-Specs:** Use dynamic attributes in factories [\#3622](https://github.com/consul/consul/pull/3622)
- **Maintenance-Specs:** Create less headings in budget investment tests [\#3685](https://github.com/consul/consul/pull/3685)
- **Maintenance-Specs:** Reduce the number of proposals in pagination spec [\#3687](https://github.com/consul/consul/pull/3687)
- **Maintenance-Specs:** Simplify after blocks in specs [\#3702](https://github.com/consul/consul/pull/3702)
- **Maintenance-Specs:** Make translatable specs faster [\#3713](https://github.com/consul/consul/pull/3713)
- **Maintenance-Specs:** Simplify data creation in specs [\#3714](https://github.com/consul/consul/pull/3714), [\#3722](https://github.com/consul/consul/pull/3722), [\#3723](https://github.com/consul/consul/pull/3723) and [\#3727](https://github.com/consul/consul/pull/3727)
- **Maintenance-Specs:** Update featured proposals specs [\#3720](https://github.com/consul/consul/pull/3720)
- **Maintenance-Specs:** Simplify testing array contents [\#3721](https://github.com/consul/consul/pull/3721) and [\#3731](https://github.com/consul/consul/pull/3731)
- **Maintenance-Specs:** Check page content from the user's perspective [\#3725](https://github.com/consul/consul/pull/3725)
- **Maintenance-Specs:** Add more tests to calculate winners [\#3726](https://github.com/consul/consul/pull/3726)
- **Maintenance-Specs:** Use `let` to remove duplication in specs [\#3728](https://github.com/consul/consul/pull/3728)
- **Maintenance-Specs:** Simplify creating  associations in specs [\#3732](https://github.com/consul/consul/pull/3732)
- **Maintenance-Specs:** Add rubocop rule for multiline blocks [\#3738](https://github.com/consul/consul/pull/3738)
- **Maintenance-Specs:** Update chromeOptions for newer versions of chromedriver [\#3808](https://github.com/consul/consul/pull/3808)
- **Maintenance-Specs:** Don't add log info messages when running tests [\#3832](https://github.com/consul/consul/pull/3832)
- **Maintenance-Specs:** Split comments and debates admin tests [\#3844](https://github.com/consul/consul/pull/3844)
- **Maintenance-Specs:** Reduce number of records in pagination tests [\#3845](https://github.com/consul/consul/pull/3845)
- **Legislation**: Allow creating proposals on process draft phase #[\#3532](https://github.com/consul/consul/pull/3532)
- **Security**: Reinforce XSS protection [\#3747](https://github.com/consul/consul/pull/3747), [\#3748](https://github.com/consul/consul/pull/3748), [\#3749](https://github.com/consul/consul/pull/3749), [\#3779](https://github.com/consul/consul/pull/3779) and [\#3874](https://github.com/consul/consul/pull/3874)
- **Security:** Add CSRF protection to Omniauth requests [\#3840](https://github.com/consul/consul/pull/3840)
- **Security:** Reduce false positives count in security reports [\#3851](https://github.com/consul/consul/pull/3851)
- **Statistics:** Improve restrictions for poll stats [\#3839](https://github.com/consul/consul/pull/3839)
- **UX/UI:** Hide information on selected proposals [\#3612](https://github.com/consul/consul/pull/3612)
- **UX/UI:** Make HTML areas independent of CKEditor [\#3802](https://github.com/consul/consul/pull/3802), [\#3824](https://github.com/consul/consul/pull/3824) and [\#3900](https://github.com/consul/consul/pull/3900)

### Fixed

- **Admin:** Avoid error when accessing final voting stats before the balloting phase [\#3603](https://github.com/consul/consul/pull/3603)
- **Admin:** Fix forward email in dashboard emails setting [\#3911](https://github.com/consul/consul/pull/3911)
- **Admin:** Fix hidden active elements in admin menu [\#3915](https://github.com/consul/consul/pull/3915) and [\#3926](https://github.com/consul/consul/pull/3926)
- **Admin:** Fix filters for investments without admin/valuator [\#3916](https://github.com/consul/consul/pull/3916)
- **Budgets:** Fix milestone publication date comparison [\#3760](https://github.com/consul/consul/pull/3760)
- **Budgets:** Don't let valuators update investments [\#3776](https://github.com/consul/consul/pull/3776)
- **Budgets:** Fix investments search with numbers in their title [\#3782](https://github.com/consul/consul/pull/3782)
- **Budgets:** Fix admin permissions for finished budgets [\#3822](https://github.com/consul/consul/pull/3822)
- **Budgets:** Expire investment cache when its image changes [\#3913](https://github.com/consul/consul/pull/3913)
- **Legislation** Categories are still shown when properties of the legislation process are changed [\#3868](https://github.com/consul/consul/pull/3868)
- **Legislation:** Fix adding blank comments to existing annotations [\#3787](https://github.com/consul/consul/pull/3787)
- **Mails:** Evaluate mailer from address at runtime [\#3684](https://github.com/consul/consul/pull/3684)
- **Maintenance:** Fix warnings in several environments [\#3791](https://github.com/consul/consul/pull/3791)
- **Maintenance:** Avoid redirects with unprotected query params  [\#3846](https://github.com/consul/consul/pull/3846)
- **Maintenance-Seeds:** Fix duplicate usernames in dev seeds task [\#3756](https://github.com/consul/consul/pull/3756)
- **Maintenance-Specs:** Check for missing feature specs for Poll::Question::Answer [\#3063](https://github.com/consul/consul/pull/3063)
- **Maintenance-Specs:** Set locales in test environment to avoid failed specs [\#3537](https://github.com/consul/consul/pull/3537)
- **Maintenance-Specs:** Fix flaky notifiable specs [\#3643](https://github.com/consul/consul/pull/3643)
- **Maintenance-Specs:** Fix flaky spec: Proposals Search Reorder results maintaing search [\#3644](https://github.com/consul/consul/pull/3644)
- **Maintenance-Specs:** Avoid Net::ReadTimeout errors in tests [\#3683](https://github.com/consul/consul/pull/3683)
- **Maintenance-Specs:** Fix flaky specs for uppercase tags [\#3686](https://github.com/consul/consul/pull/3686)
- **Maintenance-Specs:** Fix flaky officing results spec [\#3754](https://github.com/consul/consul/pull/3754)
- **Maintenance-Specs:** Fix typos in translatable spec [\#3755](https://github.com/consul/consul/pull/3755)
- **Maintenance-Specs:** Use a block to travel in time in specs [\#3797](https://github.com/consul/consul/pull/3797)
- **Maintenance-Specs:** Avoid invalid random titles in dashboard specs [\#3864](https://github.com/consul/consul/pull/3864)
- **Maintenance-Specs:** Fix flaky spec when unselecting an investment [\#3929](https://github.com/consul/consul/pull/3929)
- **Management:** Allow managers to read investment suggestions [\#3711](https://github.com/consul/consul/pull/3711)
- **Newsletters:** Don't send newsletters to unconfirmed accounts [\#3781](https://github.com/consul/consul/pull/3781)
- **Newsletters:** Fix "go back" link in newsletters [\#3861](https://github.com/consul/consul/pull/3861)
- **Polls:** Avoid error for polls results [\#3617](https://github.com/consul/consul/pull/3617)
- **Polls:** Hide polls created by users on admin poll booth assigments [\#3692](https://github.com/consul/consul/pull/3692)
- **Polls:** Fix extra records in investments and polls [\#3729](https://github.com/consul/consul/pull/3729)
- **Proposals:** Fix Infinity exceptions in hot score calculator [\#3678](https://github.com/consul/consul/pull/3678)
- **SEO:** Don't include disabled processes in sitemap [\#3891](https://github.com/consul/consul/pull/3891)
- **Translations:** Fix text confirming investment heading support [\#3656](https://github.com/consul/consul/pull/3656)
- **Translations:** Load custom locales after everything is loaded [\#3663](https://github.com/consul/consul/pull/3663)
- **Translations:** Fix share message interpolation variable [\#3698](https://github.com/consul/consul/pull/3698)
- **Translations:** Add missing spanish translations [\#3800](https://github.com/consul/consul/pull/3800)
- **Translations:** Remove translations accidentally added from en-US [\#3880](https://github.com/consul/consul/pull/3880)
- **Translations:** Remove fallbacks = true from staging, preprod and prod [\#3924](https://github.com/consul/consul/pull/3924)
- **Translations:** Fix English text written in Spanish [\#3941](https://github.com/consul/consul/pull/3941)
- **UX/UI:** Fix CKEditor height in dashboard actions form [\#3641](https://github.com/consul/consul/pull/3641)
- **UX/UI:** Precompile CKEditor dialog plugins [\#3657](https://github.com/consul/consul/pull/3657)
- **UX/UI:** Fix blank space in admin content [\#3778](https://github.com/consul/consul/pull/3778)
- **UX/UI:** Fix pagination problem on mobile [\#3830](https://github.com/consul/consul/pull/3830)
- **UX/UI:** Replace old Spanish text with org name [\#3838](https://github.com/consul/consul/pull/3838)
- **UX/UI:** Fix a tiny CSS leak [\#3854](https://github.com/consul/consul/pull/3854)
- **UX/UI:** Fix card description overflow [\#3921](https://github.com/consul/consul/pull/3921)

### Removed

- **Budgets:** Remove obsolete method to recalculate counter [\#3786](https://github.com/consul/consul/pull/3786)
- **Maintenance:** Remove obsolete code [\#3718](https://github.com/consul/consul/pull/3718), [\#3730](https://github.com/consul/consul/pull/3730) and [\#3740](https://github.com/consul/consul/pull/3740)
- **Maintenance-Deployment:** Remove tasks executed in version 1.0.0 [\#3751](https://github.com/consul/consul/pull/3751)
- **Maintenance-Deployment:** Remove custom dashboard task [\#3635](https://github.com/consul/consul/pull/3635)
- **Milestones:** Remove old milestone tables [\#3833](https://github.com/consul/consul/pull/3833)
- **Multi-language:** Bring back removal of translatable columns [\#3828](https://github.com/consul/consul/pull/3828)
- **Polls:** Remove obsolete report columns from polls [\#3827](https://github.com/consul/consul/pull/3827)
- **Proposals:** Remove people proposal model [\#3805](https://github.com/consul/consul/pull/3805)
- **Verification:** Remove duplicated local census records on deployment [\#3829](https://github.com/consul/consul/pull/3829)

## [1.0.0](https://github.com/consul/consul/tree/1.0.0) (2019-06-10)

[Full Changelog](https://github.com/consul/consul/compare/1.0.0-beta...1.0.0)

### Added

- **Accounts:** Add description field to administrator users like evaluators description [\#3389](https://github.com/consul/consul/pull/3389)
- **Admin:** Add document uploads from admin section [\#3466](https://github.com/consul/consul/pull/3466)
- **Admin:** Images and documents settings [\#3585](https://github.com/consul/consul/pull/3585)
- **Budgets:** notify by email new evaluation comments [\#3413](https://github.com/consul/consul/pull/3413)
- **Installation:** Add deploy-secrets.yml.example file [\#3516](https://github.com/consul/consul/pull/3516)
- **Installation:** Add new settings automatically on every deployment [\#3576](https://github.com/consul/consul/pull/3576)
- **Installation:** Add task to upgrade to a new release [\#3590](https://github.com/consul/consul/pull/3590)
- **Legislations:** Create Legislation::PeopleProposal model [\#3591](https://github.com/consul/consul/pull/3591)
- **Translations:** Update translations from Crowdin [\#3378](https://github.com/consul/consul/pull/3378)
- **Translations:** Admin basic customization texts [\#3488](https://github.com/consul/consul/pull/3488)
- **Translations:** Add Bosnian, Croatian, Czech, Danish, Greek, and Turkish locales [\#3571](https://github.com/consul/consul/pull/3571)
- **Newsletters:** Proposals authors user segment [\#3507](https://github.com/consul/consul/pull/3507)
- **Polls:** Add slug to polls [\#3504](https://github.com/consul/consul/pull/3504)
- **Statistics:** Add budget stats [\#3438](https://github.com/consul/consul/pull/3438)
- **Statistics:** Add admin budget stats [\#3499](https://github.com/consul/consul/pull/3499)
- **Statistics:** Add options to show advanced stats [\#3520](https://github.com/consul/consul/pull/3520)

### Changed

- **Accounts:** Change devise configuration [\#3561](https://github.com/consul/consul/pull/3561)
- **Admin:** Show count of votes associated to verified signatures [\#2616](https://github.com/consul/consul/pull/2616)
- **Budgets:** Don't destroy budgets with an associated poll [\#3492](https://github.com/consul/consul/pull/3492)
- **Budgets:** Add task to regenerate ballot\_lines\_count cache [\#3563](https://github.com/consul/consul/pull/3563)
- **Dashboard:** Hide polls created by users from proposals dashboard on admin poll index [\#3572](https://github.com/consul/consul/pull/3572)
- **Dashboard:** Allow users to delete dashboard polls [\#3574](https://github.com/consul/consul/pull/3574)
- **Maintenance:** Add Rails 5.1 compatibility [\#3562](https://github.com/consul/consul/pull/3562)
- **Maintenance:** Update migrations and schema file [\#3598](https://github.com/consul/consul/pull/3598)
- **Maintenance-Refactoring:** Refactor admin/debates and admin/comments to hidden [\#3376](https://github.com/consul/consul/pull/3376)
- **Maintenance-Refactoring:** Simplify stats caching [\#3510](https://github.com/consul/consul/pull/3510)
- **Maintenance-Refactoring:** Refactor gender and age stats methods [\#3511](https://github.com/consul/consul/pull/3511)
- **Maintenance-Refactoring:** Simplify link to poll [\#3519](https://github.com/consul/consul/pull/3519)
- **Maintenance-Refactoring:** Extract partial with mobile sticky content [\#3577](https://github.com/consul/consul/pull/3577)
- **Maintenance-Refactoring:** Use find instead of find by [\#3580](https://github.com/consul/consul/pull/3580)
- **Maintenance-Rubocop:** Allow lines to be 110 characters long by Rubocop [\#3529](https://github.com/consul/consul/pull/3529)
- **Maintenance-Seeds:** Simplify settings seeds [\#3564](https://github.com/consul/consul/pull/3564)
- **Polls:** Display all polls for current booth [\#3361](https://github.com/consul/consul/pull/3361)
- **Polls:** Allow delete polls with associated questions and answers [\#3476](https://github.com/consul/consul/pull/3476)
- **Polls:** Remove redirect for poll officers [\#3506](https://github.com/consul/consul/pull/3506)
- **Polls:** Remove token on views [\#3539](https://github.com/consul/consul/pull/3539)
- **Proposals:** Remove question and external_url fields from proposals and legislation proposals [\#3397](https://github.com/consul/consul/pull/3397)
- **Proposals:** Proposals support on mobile [\#3515](https://github.com/consul/consul/pull/3515)
- **Proposals:** Make proposals to be selected by administrators [\#3567](https://github.com/consul/consul/pull/3567)
- **Statistics:** Improve poll stats [\#3503](https://github.com/consul/consul/pull/3503)
- **Statistics:** Change stats layout [\#3512](https://github.com/consul/consul/pull/3512)
- **UX/UI:** Improve help texts on Admin UI [\#3508](https://github.com/consul/consul/pull/3508)
- **UX/UI:** Users menu [\#3509](https://github.com/consul/consul/pull/3509)
- **UX/UI:** Add help texs, links and new message section to improve UX [\#3573](https://github.com/consul/consul/pull/3573)

### Fixed

- **Budgets:** Don't show links to disabled budget results [\#3592](https://github.com/consul/consul/pull/3592)
- **Legislations:** Fix order in annotation comments with same score [\#3565](https://github.com/consul/consul/pull/3565)
- **Maintenance:** Fix obsolete `respond\_with\_bip` usage [\#3483](https://github.com/consul/consul/pull/3483)
- **Maintenance:** Remove Rspec deprecation warning [\#3530](https://github.com/consul/consul/pull/3530)
- **Maintenance:** Fix column order in schema file [\#3533](https://github.com/consul/consul/pull/3533)
- **Maintenance:** Fix indentation in schema file [\#3595](https://github.com/consul/consul/pull/3595)
- **Maintenance-Specs:** Fix typo in budget executions spec [\#3486](https://github.com/consul/consul/pull/3486)
- **Maintenance-Specs:** Remove unused \(and flaky\) card code and its spec [\#3487](https://github.com/consul/consul/pull/3487)
- **Maintenance-Specs:** Resize Capybara window back to its original size [\#3534](https://github.com/consul/consul/pull/3534)
- **Maintenance-Specs:** Check the comment is present after commenting [\#3596](https://github.com/consul/consul/pull/3596)
- **Maintenance-Specs:** Reset globalize fallbacks before every test [\#3601](https://github.com/consul/consul/pull/3601)
- **Multi-language:** Avoid duplicate records using translations [\#3581](https://github.com/consul/consul/pull/3581)
- **Polls:** Fix valid votes labels [\#3570](https://github.com/consul/consul/pull/3570)
- **Polls:** Show name and email for deleted poll officer's user account [\#3587](https://github.com/consul/consul/pull/3587)
- **UX/UI:** Always use map image from admin site customization images [\#3472](https://github.com/consul/consul/pull/3472)

### Removed

- **Maintenance-Deprecated:** Delete spending proposals [\#3569](https://github.com/consul/consul/pull/3569)

## [1.0.0-beta](https://github.com/consul/consul/compare/v0.19...1.0.0-beta) (2019-04-29)

### Added

- **Dashboard:** Add proposal's dashboard [\#3412](https://github.com/consul/consul/pull/3412)
- **Budgets:** Add on admin budget investments an advanced filter for max supports [\#3364](https://github.com/consul/consul/pull/3364)
- **Budgets:** Add price column in the admin budget investments table [\#3356](https://github.com/consul/consul/pull/3356)
- **Budgets:** Allow voting Budget Investments in booths [\#3344](https://github.com/consul/consul/pull/3344)
- **Budgets**: Budget ballot sheets UI [\#2857](https://github.com/consul/consul/pull/2857)
- **Polls:** Add officing booths [\#3345](https://github.com/consul/consul/pull/3345)
- **Polls:** Add cumulative totals to admin poll recounts list [\#3342](https://github.com/consul/consul/pull/3342)
- **Polls:** Verify poll ballots [\#2858](https://github.com/consul/consul/pull/2858)
- **Maintenance-Seeds:** Include default custom pages in developers seed [\#3402](https://github.com/consul/consul/pull/3402)
- **Maintenance-Rubocop:** Enable rubocop rules in config and seed files [\#3380](https://github.com/consul/consul/pull/3380)
- **Maintenance-Rubocop:** Add ERB Lint configuration file [\#3379](https://github.com/consul/consul/pull/3379)
- **Maintenance-Rubocop:** Add CoffeeLint rules [\#3338](https://github.com/consul/consul/pull/3338)
- **Maintenance-IDEs:** Add Intellij IDE project settings to gitignore [\#3430](https://github.com/consul/consul/pull/3430)

### Changed

- **Budgets:** Update texts on check my ballot links [\#3407](https://github.com/consul/consul/pull/3407)
- **Budgets:** Change admin budget investments subfilters from tabs to advanced filter checkboxes [\#3351](https://github.com/consul/consul/pull/3351)
- **Proposals:** Add rake to move external\_url to description [\#3396](https://github.com/consul/consul/pull/3396)
- **Verification:** Use min age to participate setting on verification residence form [\#3399](https://github.com/consul/consul/pull/3399)
- **Translations:** Generalize i18n texts [\#3337](https://github.com/consul/consul/pull/3337)
- **Admin:** Improve Admin settings section [\#3387](https://github.com/consul/consul/pull/3387)
- **Customization:** Default site customization pages [\#3353](https://github.com/consul/consul/pull/3353)
- **UX/UI:** Improve UX on admin section [\#3334](https://github.com/consul/consul/pull/3334)
- **Maintenance-README:** Update docs link on README [\#3418](https://github.com/consul/consul/pull/3418)
- **Maintenance-README:** Update README [\#3417](https://github.com/consul/consul/pull/3417)
- **Maintenance-README:** Update core team members, contributors and alumni [\#3440](https://github.com/consul/consul/pull/3440)
- **Maintenance-Specs:** Use 3 Travis nodes for running the test suite [\#3416](https://github.com/consul/consul/pull/3416)
- **Maintenance-Specs:** Simplify poll factories [\#3384](https://github.com/consul/consul/pull/3384)
- **Maintenance-Specs:** Fix flaky spec: Ballots Groups Change my heading [\#3460](https://github.com/consul/consul/pull/3460)
- **Maintenance-Rubocop:** Add missing double quotes [\#3404](https://github.com/consul/consul/pull/3404)
- **Maintenance-Refactoring:** Change single quotes to double quotes everywhere [\#3370](https://github.com/consul/consul/pull/3370)
- **Maintenance-Refactoring:** Change single quotes to double quotes for views [\#3369](https://github.com/consul/consul/pull/3369)
- **Maintenance-Refactoring:** Change single quotes to double quotes for models [\#3362](https://github.com/consul/consul/pull/3362)
- **Maintenance-Refactoring:** Use double quotes in CoffeeScript files [\#3339](https://github.com/consul/consul/pull/3339)
- **Maintenance-Refactoring:** Change single quotes to double quotes for controllers [\#3360](https://github.com/consul/consul/pull/3360)
- **Maintenance-Translations:** Update share messages interpolation variables [\#3452](https://github.com/consul/consul/pull/3452)
- **Maintenance-Gems:** Bump Rails version to 4.2.11.1 [\#3358](https://github.com/consul/consul/pull/3358)
- **Maintenance-gems:** Upgrade to rails 5 [\#3414](https://github.com/consul/consul/pull/3414)

### Fixed

- **Dashboard:** Cleanup Rails5 dashboard [\#3464](https://github.com/consul/consul/pull/3464)
- **Budgets:** Show unfeasible budget investment messages only when valuation finished [\#3340](https://github.com/consul/consul/pull/3340)
- **Budgets:** Fix bug moderator can't print voted investments in balloting phase [\#3443](https://github.com/consul/consul/pull/3443)
- **Polls:** Display 'Validate document' menu item only when applicable [\#3343](https://github.com/consul/consul/pull/3343)
- **Polls:** Improvements about displaying results for voted polls [\#3341](https://github.com/consul/consul/pull/3341)
- **Polls**: Enable options to show stats and results with any type of voter [\#3155](https://github.com/consul/consul/pull/3155)
- **Legislations:** Fix legislation process feed order [\#3400](https://github.com/consul/consul/pull/3400)
- **Accessibility:** Fix accessibility and HTML warnings [\#3366](https://github.com/consul/consul/pull/3366)
- **Images:** Keep images uploaded with CKEditor when deploying [\#3367](https://github.com/consul/consul/pull/3367)
- **Maintenance-Exception:** Fix exception when confirming an invalid token [\#3432](https://github.com/consul/consul/pull/3432)
- **Maintenance-Exception:** Require logged in user if navigate to /welcome [\#3385](https://github.com/consul/consul/pull/3385)
- **Maintenance-Specs:** Fix sort by random inconsistencies [\#3420](https://github.com/consul/consul/pull/3420)
- **Maintenance-Specs:** Fix investment pagination tests [\#3405](https://github.com/consul/consul/pull/3405)
- **Maintenance-gems:** Use Rails 5 conventions in ballot migrations [\#3453](https://github.com/consul/consul/pull/3453)
- **Maintenance-gems:** Fix Invalid Authenticity Token with Rails 5 [\#3454](https://github.com/consul/consul/pull/3454)
- **Maintenance-gems:** Handle AccessDenied in management sessions [\#3458](https://github.com/consul/consul/pull/3458)
- **Maintenance-gems:** Fix InvalidCrossOriginRequest response [\#3459](https://github.com/consul/consul/pull/3459)
- **Maintenance-gems:** Add lib folder path to eager_load_paths [\#3465](https://github.com/consul/consul/pull/3465)

### Removed

- **Maintenance-Deprecated:** Remove obsolete rake tasks [\#3401](https://github.com/consul/consul/pull/3401)
- **Maintenance-Deprecated:** Add rake task to check for spending proposals [\#3441](https://github.com/consul/consul/pull/3441)

## [v0.19](https://github.com/consul/consul/compare/v0.18.1...v0.19) (2019-02-27)

### Added

- **Admin:** Add cards to custom pages [\#3149](https://github.com/consul/consul/pull/3149)
- **Design/UX:** Refactor processes header colors and custom pages [\#3249](https://github.com/consul/consul/pull/3249)
- **Legislation:** Add image to legislation processes and banner colors [\#3152](https://github.com/consul/consul/pull/3152)
- **Mails:** Configurable email interceptor by environment [\#3251](https://github.com/consul/consul/pull/3251)
- **Maintenance-Rubocop:** Enable useless assignment rubocop rule [\#3120](https://github.com/consul/consul/pull/3120)
- **Maintenance-Rubocop:** Fix literal as condition [\#3313](https://github.com/consul/consul/pull/3313)
- **Milestones:** Manage milestone progress bars [\#3195](https://github.com/consul/consul/pull/3195)
- **Milestones:** Refactor milestones css [\#3196](https://github.com/consul/consul/pull/3196)
- **Milestones:** Add progress bar dev seeds [\#3197](https://github.com/consul/consul/pull/3197)
- **Milestones:** Add progress bars to milestones public view [\#3228](https://github.com/consul/consul/pull/3228)
- **Multi-language:** Make budgets translatable [\#3296](https://github.com/consul/consul/pull/3296)
- **Polls:** Add a description for open polls [\#3303](https://github.com/consul/consul/pull/3303)
- **Translations:** add new Russian translation [\#3204](https://github.com/consul/consul/pull/3204)
- **Translations:** add new Russian translation [\#3205](https://github.com/consul/consul/pull/3205)
- **Translations:** add new Russian translation [\#3206](https://github.com/consul/consul/pull/3206)
- **Translations:** add new Russian translation [\#3207](https://github.com/consul/consul/pull/3207)
- **Translations:** add new Russian translation [\#3208](https://github.com/consul/consul/pull/3208)
- **Translations:** add new Russian translation [\#3209](https://github.com/consul/consul/pull/3209)
- **Translations:** add new Russian translation [\#3210](https://github.com/consul/consul/pull/3210)
- **Translations:** add new Russian translation [\#3211](https://github.com/consul/consul/pull/3211)
- **Translations:** add new Russian translation [\#3212](https://github.com/consul/consul/pull/3212)
- **Translations:** add new Russian translation [\#3213](https://github.com/consul/consul/pull/3213)
- **Translations:** add new Russian translation [\#3214](https://github.com/consul/consul/pull/3214)
- **Translations:** add new Russian translation [\#3215](https://github.com/consul/consul/pull/3215)
- **Translations:** add new Russian translation [\#3216](https://github.com/consul/consul/pull/3216)
- **Translations:** add new Russian translation [\#3217](https://github.com/consul/consul/pull/3217)
- **Translations:** add new Russian translation [\#3218](https://github.com/consul/consul/pull/3218)
- **Translations:** add new Russian translation [\#3219](https://github.com/consul/consul/pull/3219)
- **Translations:** add new Russian translation [\#3220](https://github.com/consul/consul/pull/3220)
- **Translations:** add new Russian translation [\#3221](https://github.com/consul/consul/pull/3221)
- **Translations:** add new Russian translation [\#3222](https://github.com/consul/consul/pull/3222)
- **Translations:** add new Russian translation [\#3223](https://github.com/consul/consul/pull/3223)
- **Translations:** add new Russian translation [\#3224](https://github.com/consul/consul/pull/3224)
- **Translations:** add new Russian translation [\#3225](https://github.com/consul/consul/pull/3225)
- **Translations:** add new Russian translation [\#3226](https://github.com/consul/consul/pull/3226)
- **Translations:** New Crowdin translations [\#3305](https://github.com/consul/consul/pull/3305)
- **Translations:** Add locales for Indonesian, Russian, Slovak and Somali [\#3309](https://github.com/consul/consul/pull/3309)
- **Translations:** Remove untranslated locales [\#3310](https://github.com/consul/consul/pull/3310)

### Changed

- **Admin:** Admin tables order - sorting [\#3148](https://github.com/consul/consul/pull/3148)
- **Admin:** Hide polls results and stats to admins [\#3229](https://github.com/consul/consul/pull/3229)
- **Admin:** Allow change map image from admin [\#3230](https://github.com/consul/consul/pull/3230)
- **Admin:** Allow admins delete poll answer documents [\#3231](https://github.com/consul/consul/pull/3231)
- **Admin:** Admin polls list [\#3253](https://github.com/consul/consul/pull/3253)
- **Admin:** Show all system emails in Admin section [\#3326](https://github.com/consul/consul/pull/3326)
- **Admin:** Improve Admin settings section [\#3328](https://github.com/consul/consul/pull/3328)
- **Budgets:** Show current phase as selected on phase select on admin budgets form [\#3203](https://github.com/consul/consul/pull/3203)
- **Budgets:** Do not display alert when supporting in a group with a single heading [\#3278](https://github.com/consul/consul/pull/3278)
- **Budgets:** Include heading names in "headings limit reached" alert  [\#3290](https://github.com/consul/consul/pull/3290)
- **Budgets:** Consider having valuator group as having valuator [\#3314](https://github.com/consul/consul/pull/3314)
- **Budgets:** Show all investments in the map [\#3318](https://github.com/consul/consul/pull/3318)
- **Design/UX:** Improve UI of budgets index page [\#3250](https://github.com/consul/consul/pull/3250)
- **Design/UX:** Allow select column width for widget cards [\#3252](https://github.com/consul/consul/pull/3252)
- **Design/UX:** Change layout on homepage if feed debates and proposals are enabled [\#3269](https://github.com/consul/consul/pull/3269)
- **Design/UX:** Improve color picker on admin legislation process [\#3277](https://github.com/consul/consul/pull/3277)
- **Design/UX:** Removes next/incoming filters [\#3280](https://github.com/consul/consul/pull/3280)
- **Design/UX:** Add sorting icons to sortable tables [\#3324](https://github.com/consul/consul/pull/3324)
- **Design/UX:** Improve UX on admin section [\#3329](https://github.com/consul/consul/pull/3329)
- **Legislation:** Remove help and recommendations on legislation proposal new form [\#3200](https://github.com/consul/consul/pull/3200)
- **Legislation:** Sort Legislation Processes by descending start date [\#3202](https://github.com/consul/consul/pull/3202)
- **Maps:** Always show markers on budgets index map [\#3267](https://github.com/consul/consul/pull/3267)
- **Maintenance-Refactorings:** Add pending specs proposal notification limits [\#3174](https://github.com/consul/consul/pull/3174)
- **Maintenance-Refactorings:** Refactors images attributes [\#3170](https://github.com/consul/consul/pull/3170)
- **Maintenance-Refactorings:** Use find instead of find\_by\_id [\#3234](https://github.com/consul/consul/pull/3234)
- **Maintenance-Refactorings:** LegacyLegislation migration cleanup [\#3275](https://github.com/consul/consul/pull/3275)
- **Maintenance-Refactorings:** Replace sccs lint string quotes to double quotes [\#3281](https://github.com/consul/consul/pull/3281)
- **Maintenance-Refactorings:** Change single quotes to double quotes in folder /spec [\#3287](https://github.com/consul/consul/pull/3287)
- **Maintenance-Refactorings:** Reuse image attributes in legislation processes [\#3319](https://github.com/consul/consul/pull/3319)
- **Newsletters:** Send newsletter emails in order [\#3274](https://github.com/consul/consul/pull/3274)
- **Tags:** Set tags max length to 160 [\#3264](https://github.com/consul/consul/pull/3264)
- **Translations:** Update budgets confirm group es translation [\#3198](https://github.com/consul/consul/pull/3198)
- **Votes:** Use votes score instead of total votes on debates and legislation proposals [\#3291](https://github.com/consul/consul/pull/3291)

### Fixed

- **Budgets:** Show unfeasible and unselected investments for finished budgets [\#3272](https://github.com/consul/consul/pull/3272)
- **Design/UX:** Fix UI details for a better UX and design [\#3323](https://github.com/consul/consul/pull/3323)
- **Design/UX:** Budgets UI minor fixes [\#3268](https://github.com/consul/consul/pull/3268)
- **Polls:** Delete Booth Shifts with associated data [\#3292](https://github.com/consul/consul/pull/3292)
- **Proposals:** Fix random proposals order in the same session [\#3321](https://github.com/consul/consul/pull/3321)
- **Tags:** Fix valuation tags being overwritten [\#3330](https://github.com/consul/consul/pull/3330)
- **Translations:** Fix i18n and UI minor details [\#3191](https://github.com/consul/consul/pull/3191)
- **Translations:** Return a String in I18n method 'pluralize' [\#3307](https://github.com/consul/consul/pull/3307)

## [0.18.1](https://github.com/consul/consul/compare/v0.18...v0.18.1) (2019-01-17)

### Added

- **Legislation:** Legislation process homepage phase [\#3188](https://github.com/consul/consul/pull/3188)
- **Legislation:** Show documents on processes proposals phase [\#3136](https://github.com/consul/consul/pull/3136)
- **Maintenance-Refactorings:** Remove semicolons from controllers [\#3160](https://github.com/consul/consul/pull/3160)
- **Maintenance-Refactorings:** Remove before action not used [\#3167](https://github.com/consul/consul/pull/3167)
- **Maintenance-Rubocop:** Enable double quotes rubocop rule [\#3175](https://github.com/consul/consul/pull/3175)
- **Maintenance-Rubocop:** Enable line length rubocop rule [\#3165](https://github.com/consul/consul/pull/3165)
- **Maintenance-Rubocop:** Add rubocop rule to indent private methods [\#3134](https://github.com/consul/consul/pull/3134)

### Changed

- **Admin:** Improve CRUD budgets and content blocks [\#3173](https://github.com/consul/consul/pull/3173)
- **Design/UX:** new CRUD budgets, content blocks and heading map [\#3150](https://github.com/consul/consul/pull/3150)
- **Design/UX:** Processes key dates [\#3137](https://github.com/consul/consul/pull/3137)

### Fixed

- **Admin:** checks for deleted proposals [\#3154](https://github.com/consul/consul/pull/3154)
- **Admin:** Add default order for admin budget investments list [\#3151](https://github.com/consul/consul/pull/3151)
- **Budgets:** Bug Management Cannot create Budget Investment without a map location [\#3133](https://github.com/consul/consul/pull/3133)

## [0.18.0](https://github.com/consul/consul/compare/v0.17...v0.18) (2018-12-27)

### Added

- **Admin:** Admin poll questions index [\#3123](https://github.com/consul/consul/pull/3123)
- **Budgets:** Added feature to add content block to headings in sidebar [\#3043](https://github.com/consul/consul/pull/3043)
- **Budgets:** Add map to sidebar on Heading's page [\#3038](https://github.com/consul/consul/pull/3038)
- **Budgets:** Budget executions [\#3023](https://github.com/consul/consul/pull/3023)
- **Budgets:** Budget execution list [\#2864](https://github.com/consul/consul/pull/2864)
- **Design/UX:** Administrator ID [\#3056](https://github.com/consul/consul/pull/3056)
- **Legislation:** Draft phase on legislation processes [\#3105](https://github.com/consul/consul/pull/3105)
- **Legislation:** add homepage for legislation processes [\#3091](https://github.com/consul/consul/pull/3091)
- **Legislation:** Adds draft phase functionality in legislation processes [\#3048](https://github.com/consul/consul/pull/3048)
- **Maintenance:** Widgets dev seeds [\#3104](https://github.com/consul/consul/pull/3104)
- **Maintenance:** Add web sections to seeds [\#3037](https://github.com/consul/consul/pull/3037)
- **Maintenance-Rubocop:** Apply Rubocop not\_to rule [\#3118](https://github.com/consul/consul/pull/3118)
- **Maintenance-Rubocop:** Add not\_to Rubocop rule [\#3112](https://github.com/consul/consul/pull/3112)
- **Maintenance-Rubocop:** Add a "Reviewed by Hound" badge [\#3093](https://github.com/consul/consul/pull/3093)
- **Maintenance-Specs:** Add missing feature spec: Proposal Notifications In-app notifications from the proposal's author group notifications for the same proposal [\#3066](https://github.com/consul/consul/pull/3066)
- **Maintenance-Specs:** Add missing feature spec: Admin poll questions Create from successful proposal show [\#3065](https://github.com/consul/consul/pull/3065)
- **Maintenance-Specs:** Add missing feature spec Admin budget investments Edit Do not display valuators of an assigned group [\#3064](https://github.com/consul/consul/pull/3064)
- **Milestones:** Edit only existing languages in milestones summary [\#3103](https://github.com/consul/consul/pull/3103)
- **Milestones:** Update milestone status texts [\#3102](https://github.com/consul/consul/pull/3102)
- **Milestones:** Fix milestone validation [\#3101](https://github.com/consul/consul/pull/3101)
- **Milestones:** Add milestones to legislation processes  [\#3100](https://github.com/consul/consul/pull/3100)
- **Milestones:** Add milestones to proposals [\#3099](https://github.com/consul/consul/pull/3099)
- **Milestones:** Fix budget investment milestone translations migration [\#3097](https://github.com/consul/consul/pull/3097)
- **Milestones:** Make milestones code reusable [\#3095](https://github.com/consul/consul/pull/3095)
- **Milestones:** Make milestones controller polymorphic [\#3083](https://github.com/consul/consul/pull/3083)
- **Milestones:** Make milestones polymorphic [\#3057](https://github.com/consul/consul/pull/3057)
- **Polls:** Polls voted by [\#3089](https://github.com/consul/consul/pull/3089)
- **Proposals:** Featured proposals [\#3081](https://github.com/consul/consul/pull/3081)
- **Translations:** Added Slovenian translations [\#3062](https://github.com/consul/consul/pull/3062)
- **Translations:** New Crowdin translations [\#3050](https://github.com/consul/consul/pull/3050)
- **Translations:** Maintain translations for other languages after updatin main language [\#3046](https://github.com/consul/consul/pull/3046)
- **Translations:** New Crowdin translations [\#3005](https://github.com/consul/consul/pull/3005)
- **Translations:** Update i18n from Crowdin  [\#2998](https://github.com/consul/consul/pull/2998)

### Changed

- **Admin:** Improve action buttons aspect for small screens [\#3027](https://github.com/consul/consul/pull/3027)
- **Admin:** Improve visualization for small resolution [\#3025](https://github.com/consul/consul/pull/3025)
- **Admin:** Budgets admin [\#3012](https://github.com/consul/consul/pull/3012)
- **Budgets:** Budget investments social share [\#3053](https://github.com/consul/consul/pull/3053)
- **Design/UX:** Documents title [\#3131](https://github.com/consul/consul/pull/3131)
- **Design/UX:** Proposal create question [\#3122](https://github.com/consul/consul/pull/3122)
- **Design/UX:** Budget investments price explanation [\#3121](https://github.com/consul/consul/pull/3121)
- **Design/UX:** Change CRUD for budget groups and headings [\#3106](https://github.com/consul/consul/pull/3106)
- **Design/UX:** UI design [\#3080](https://github.com/consul/consul/pull/3080)
- **Design/UX:** Budgets unselected message [\#3033](https://github.com/consul/consul/pull/3033)
- **Design/UX:** Hide Featured section on Home Page if there are no cards [\#2899](https://github.com/consul/consul/pull/2899)
- **Maintenance:** Simplify pull request template [\#3088](https://github.com/consul/consul/pull/3088)
- **Maintenance:** Removes references to deleted general terms page [\#3079](https://github.com/consul/consul/pull/3079)
- **Maintenance:** Pages texts [\#3042](https://github.com/consul/consul/pull/3042)
- **Maintenance:** Removed icon\_home and fixed corresponding test [\##2970](https://github.com/consul/consul/pull/2970)
- **Maintenance-Gems:** \[Security\] Bump rails from 4.2.10 to 4.2.11 [\#3070](https://github.com/consul/consul/pull/3070)
- **Maintenance-Gems:** Bump database\_cleaner from 1.6.2 to 1.7.0 [\#3014](https://github.com/consul/consul/pull/3014)
- **Maintenance-Gems:** Bump rspec-rails from 3.7.2 to 3.8.1 [\#3003](https://github.com/consul/consul/pull/3003)
- **Maintenance-Gems:** Bump uglifier from 4.1.3 to 4.1.19 [\#3002](https://github.com/consul/consul/pull/3002)
- **Maintenance-Gems:** \[Security\] Bump rack from 1.6.10 to 1.6.11 [\#3000](https://github.com/consul/consul/pull/3000)
- **Maintenance-Gems:** Bump knapsack\_pro from 0.53.0 to 1.1.0 [\#2999](https://github.com/consul/consul/pull/2999)
- **Maintenance-Gems:** Bump letter\_opener\_web from 1.3.2 to 1.3.4 [\#2957](https://github.com/consul/consul/pull/2957)
- **Maintenance-Gems:** Bump rollbar from 2.15.5 to 2.18.0 [\#2923](https://github.com/consul/consul/pull/2923)
- **Maintenance-Gems:** Bump cancancan from 2.1.2 to 2.3.0 [\#2901](https://github.com/consul/consul/pull/2901)
- **Maintenance-Refactorings:** Remove custom "toda la ciudad" code [\#3111](https://github.com/consul/consul/pull/3111)
- **Maintenance-Refactorings:** Refactor legislation process subnav [\#3074](https://github.com/consul/consul/pull/3074)
- **Maintenance-Refactorings:** Rename Admin::Proposals to Admin::HiddenProposals  [\#3073](https://github.com/consul/consul/pull/3073)
- **Maintenance-Refactorings:** Budget investment show [\#3041](https://github.com/consul/consul/pull/3041)
- **Proposals:** Optimize task reset\_hot\_score [\#3116](https://github.com/consul/consul/pull/3116)
- **Proposals:** New algorithm for filter 'most active' [\#3098](https://github.com/consul/consul/pull/3098)
- **Translations:** Bring back date order translations [\#3127](https://github.com/consul/consul/pull/3127)
- **Translations:** i18n remove date.order key [\#3007](https://github.com/consul/consul/pull/3007)

### Fixed

- **Admin:** Fix pagination after selecting/unselecting budget investment [\#3034](https://github.com/consul/consul/pull/3034)
- **Admin:** Admin menu link [\#3032](https://github.com/consul/consul/pull/3032)
- **Design/UX:** Honeypot on users sign up form [\#3124](https://github.com/consul/consul/pull/3124)
- **Design/UX:** Fix scroll jump voting investments [\#3113](https://github.com/consul/consul/pull/3113)
- **Design/UX:** Globalize tabs [\#3054](https://github.com/consul/consul/pull/3054)
- **Design/UX:** Help feature [\#3040](https://github.com/consul/consul/pull/3040)
- **Design/UX:** Fix misleading title on account creation confirmation page (en, fr) [\#2944](https://github.com/consul/consul/pull/2944)
- **Legislation:** Fixes legislation processes key dates active class [\#3020](https://github.com/consul/consul/pull/3020)
- **Maintenance:** Fix scope warning  [\#3071](https://github.com/consul/consul/pull/3071)
- **Maintenance** Admin poll officers [\#3055](https://github.com/consul/consul/pull/3055)
- **Maintenance-Rubocop:** Remove trailing whitespace [\#3094](https://github.com/consul/consul/pull/3094)
- **Maintenance-Specs:** Fix flaky spec checking price without currency symbol [\#3115](https://github.com/consul/consul/pull/3115)
- **Maintenance-Specs:** Fix flaky localization specs [\#3096](https://github.com/consul/consul/pull/3096)
- **Maintenance-Specs:** Add frozen time condition to proposals phase spec [\#3090](https://github.com/consul/consul/pull/3090)
- **Maintenance-Specs:** Fix flaky spec: Legislation Proposals Each user has a different and consistent random proposals order [\#3085](https://github.com/consul/consul/pull/3085)
- **Maintenance-Specs:** Fix flaky spec: Each user has a different and consistent random proposals order [\#3076](https://github.com/consul/consul/pull/3076)
- **Maintenance-Specs:** Fix flaky spec: Welcome screen is not shown to organizations  [\#3072](https://github.com/consul/consul/pull/3072)
- **Maintenance-Specs:** Fix failing spec: Budget::Investment Reclassification store\_reclassified\_votes stores the votes for a reclassified investment [\#3067](https://github.com/consul/consul/pull/3067)
- **Maintenance-Specs:** Fix failing spec: Poll::Shift officer\_assignments creates and destroy corresponding officer\_assignments [\#3061](https://github.com/consul/consul/pull/3061)
- **Maintenance-Specs:** Update debates\_spec.rb [\#3029](https://github.com/consul/consul/pull/3029)
- **Maintenance-Specs:** Fix flaky spec: Admin budget investment mark/unmark visible to valuators [\#3008](https://github.com/consul/consul/pull/3008)
- **Polls:** Fix poll results accuracy [\#3030](https://github.com/consul/consul/pull/3030)
- **Translations:** Legislation dates [\#3039](https://github.com/consul/consul/pull/3039)
- **Translations:** Fixes english translations [\#3011](https://github.com/consul/consul/pull/3011)
- **Translations:** i18n remove duplicate locale folders [\#3006](https://github.com/consul/consul/pull/3006)
- **Valuation:** Fix crash in valuation when there are no budgets [\#3128](https://github.com/consul/consul/pull/3128)

## [0.17.0](https://github.com/consul/consul/compare/v0.16...v0.17) - 2018-10-31

### Added

- **Multi-language:** Migrate globalize data [\#2986](https://github.com/consul/consul/pull/2986)
- **Multi-language:** Update custom pages translations [\#2952](https://github.com/consul/consul/pull/2952)
- **Multi-language:** Make homepage content translatable [\#2924](https://github.com/consul/consul/pull/2924)
- **Multi-language:** Make collaborative legislation translatable [\#2912](https://github.com/consul/consul/pull/2912)
- **Multi-language:** Make admin notifications translatable [\#2910](https://github.com/consul/consul/pull/2910)
- **Multi-language:** Refactor translatable specs [\#2903](https://github.com/consul/consul/pull/2903)
- **Multi-language:** Refactor code shared by admin-translatable resources [\#2896](https://github.com/consul/consul/pull/2896)
- **Multi-language:** Change Translatable implementation to accommodate new requirements [\#2886](https://github.com/consul/consul/pull/2886)
- **Multi-language:** Make banners translatable [\#2865](https://github.com/consul/consul/pull/2865)
- **Multi-language:** Fix translatable bugs [\#2985](https://github.com/consul/consul/pull/2985)
- **Multi-language:** Make polls translatable [\#2914](https://github.com/consul/consul/pull/2914)
- **Multi-language:** Updates translatable custom pages [\#2913](https://github.com/consul/consul/pull/2913)
- **Translations:** Add all available languages [\#2964](https://github.com/consul/consul/pull/2964)
- **Translations:** Fix locale folder names [\#2963](https://github.com/consul/consul/pull/2963)
- **Translations:** Update translations from Crowdin [\#2961](https://github.com/consul/consul/pull/2961)
- **Translations:** Display language name or language key [\#2949](https://github.com/consul/consul/pull/2949)
- **Translations:** Avoid InvalidPluralizationData exception when missing translations [\#2936](https://github.com/consul/consul/pull/2936)
- **Translations:** Changes allegations dates label [\#2915](https://github.com/consul/consul/pull/2915)
- **Maintenance-Rubocop:** Add Hound basic configuration [\#2987](https://github.com/consul/consul/pull/2987)
- **Maintenance-Rubocop:** Update rubocop rules [\#2925](https://github.com/consul/consul/pull/2925)
- **Maintenance-Rubocop:** Fix Rubocop warnings for Admin controllers [\#2880](https://github.com/consul/consul/pull/2880)
- **Design/UX:** Adds status icons on polls poll group [\#2860](https://github.com/consul/consul/pull/2860)
- **Design/UX:** Feature help page [\#2933](https://github.com/consul/consul/pull/2933)
- **Design/UX:** Adds enable help page task [\#2960](https://github.com/consul/consul/pull/2960)
- **Budgets:** Allow select winner legislation proposals [\#2950](https://github.com/consul/consul/pull/2950)
- **Legislation-Proposals:** Add legislation proposal's categories [\#2948](https://github.com/consul/consul/pull/2948)
- **Legislation-Proposals:** Admin permissions in legislation proposals [\#2945](https://github.com/consul/consul/pull/2945)
- **Legislation-Proposals:** Random legislation proposal's order & pagination [\#2942](https://github.com/consul/consul/pull/2942)
- **Legislation-Proposals:** Legislation proposals imageable [\#2922](https://github.com/consul/consul/pull/2922)
- **CKeditor:** Bring back CKEditor images button [\#2977](https://github.com/consul/consul/pull/2977)
- **CKeditor:** Ckeditor4 update [\#2876](https://github.com/consul/consul/pull/2876)
- **Installation:** Add placeholder configuration for SMTP [\#2900](https://github.com/consul/consul/pull/2900)

### Changed

- **Newsletters:** Newsletter updates [\#2992](https://github.com/consul/consul/pull/2992)
- **Maintenance-Gems:** \[Security\] Bump rubyzip from 1.2.1 to 1.2.2 [\#2879](https://github.com/consul/consul/pull/2879)
- **Maintenance-Gems:** \[Security\] Bump nokogiri from 1.8.2 to 1.8.4 [\#2878](https://github.com/consul/consul/pull/2878)
- **Maintenance-Gems:** \[Security\] Bump ffi from 1.9.23 to 1.9.25 [\#2877](https://github.com/consul/consul/pull/2877)
- **Maintenance-Gems:** Bump jquery-rails from 4.3.1 to 4.3.3 [\#2929](https://github.com/consul/consul/pull/2929)
- **Maintenance-Gems:** Bump browser from 2.5.2 to 2.5.3 [\#2928](https://github.com/consul/consul/pull/2928)
- **Maintenance-Gems:** Bump delayed\_job\_active\_record from 4.1.2 to 4.1.3 [\#2927](https://github.com/consul/consul/pull/2927)
- **Maintenance-Gems:** Bump rubocop-rspec from 1.24.0 to 1.26.0 [\#2926](https://github.com/consul/consul/pull/2926)
- **Maintenance-Gems:** Bump paranoia from 2.4.0 to 2.4.1 [\#2909](https://github.com/consul/consul/pull/2909)
- **Maintenance-Gems:** Bump ancestry from 3.0.1 to 3.0.2 [\#2908](https://github.com/consul/consul/pull/2908)
- **Maintenance-Gems:** Bump i18n-tasks from 0.9.20 to 0.9.25 [\#2906](https://github.com/consul/consul/pull/2906)
- **Maintenance-Gems:** Bump coveralls from 0.8.21 to 0.8.22 [\#2905](https://github.com/consul/consul/pull/2905)
- **Maintenance-Gems:** Bump scss\_lint from 0.54.0 to 0.55.0 [\#2895](https://github.com/consul/consul/pull/2895)
- **Maintenance-Gems:** Bump unicorn from 5.4.0 to 5.4.1 [\#2894](https://github.com/consul/consul/pull/2894)
- **Maintenance-Gems:** Bump mdl from 0.4.0 to 0.5.0 [\#2892](https://github.com/consul/consul/pull/2892)
- **Maintenance-Gems:** Bump savon from 2.11.2 to 2.12.0 [\#2891](https://github.com/consul/consul/pull/2891)
- **Maintenance-Gems:** Bump capistrano-rails from 1.3.1 to 1.4.0 [\#2884](https://github.com/consul/consul/pull/2884)
- **Maintenance-Gems:** Bump autoprefixer-rails from 8.2.0 to 9.1.4 [\#2881](https://github.com/consul/consul/pull/2881)
- **Maintenance-Gems:** Upgrade gem coffee-rails to version 4.2.2 [\#2837](https://github.com/consul/consul/pull/2837)
- **Maintenance-Refactorings:** Adds custom javascripts folder [\#2921](https://github.com/consul/consul/pull/2921)
- **Maintenance-Refactorings:** Test suite maintenance [\#2888](https://github.com/consul/consul/pull/2888)
- **Maintenance-Refactorings:** Replace `.all.each` with `.find\_each` to reduce memory usage [\#2887](https://github.com/consul/consul/pull/2887)
- **Maintenance-Refactorings:** Split factories [\#2838](https://github.com/consul/consul/pull/2838)
- **Maintenance-Refactorings:** Change spelling for constant to TITLE\_LENGTH\_RANGE [\#2966](https://github.com/consul/consul/pull/2966)
- **Maintenance-Refactorings:** Remove described class cop [\#2990](https://github.com/consul/consul/pull/2990)
- **Maintenance-Refactorings:** Ease customization in processes controller [\#2982](https://github.com/consul/consul/pull/2982)
- **Maintenance-Refactorings:** Fix a misleading comment [\#2844](https://github.com/consul/consul/pull/2844)
- **Maintenance-Refactorings:** Simplify legislation proposals customization [\#2946](https://github.com/consul/consul/pull/2946)
- **Social-Share:** Improves social share messages for proposals [\#2994](https://github.com/consul/consul/pull/2994)

### Fixed

- **Maintenance-Specs:** Fix flaky specs: proposals and legislation Voting comments Update [\#2989](https://github.com/consul/consul/pull/2989)
- **Maintenance-Specs:** Fix flaky spec: Admin legislation questions Update Valid legislation question [\#2976](https://github.com/consul/consul/pull/2976)
- **Maintenance-Specs:** Fix flaky spec: Admin feature flags Enable a disabled feature  [\#2967](https://github.com/consul/consul/pull/2967)
- **Maintenance-Specs:** Fix flaky spec for translations [\#2962](https://github.com/consul/consul/pull/2962)
- **Maintenance-Specs:** Fix flaky spec: Admin legislation draft versions Update Valid legislation draft version [\#2995](https://github.com/consul/consul/pull/2995)
- **Maintenance-Specs:** Fix pluralization spec when using different default locale [\#2973](https://github.com/consul/consul/pull/2973)
- **Maintenance-Specs:** Fix time related specs [\#2911](https://github.com/consul/consul/pull/2911)
- **Design/UX:** UI design [\#2983](https://github.com/consul/consul/pull/2983)
- **Design/UX:** Custom fonts [\#2916](https://github.com/consul/consul/pull/2916)
- **Design/UX:** Show active tab in custom info texts [\#2898](https://github.com/consul/consul/pull/2898)
- **Design/UX:** Fix navigation menu under Legislation::Proposal show view [\#2835](https://github.com/consul/consul/pull/2835)
- **Social-Share:** Fix bug in facebook share link [\#2852](https://github.com/consul/consul/pull/2852)

## [0.16.0](https://github.com/consul/consul/compare/v0.15...v0.16) - 2018-07-16

### Added

- **Budgets:** Budgets investment show messages [\#2766](https://github.com/consul/consul/pull/2766)
- **Budgets:** Add Valuator Group name validation & related specs [\#2576](https://github.com/consul/consul/pull/2576)
- **Budgets:** Investment milestone's project status [\#2706](https://github.com/consul/consul/pull/2706)
- **Budgets:** Budget statuses [\#2705](https://github.com/consul/consul/pull/2705)
- **Budgets:** Display only selected budget investmests in "Publishing prices" phase [\#2657](https://github.com/consul/consul/pull/2657)
- **Budgets:** Budgets see results [\#2620](https://github.com/consul/consul/pull/2620)
- **Budgets:** Show 'See Results' button in budget admin panel [\#2632](https://github.com/consul/consul/pull/2632)
- **Budgets:** Adds message to selected budget investments [\#2622](https://github.com/consul/consul/pull/2622)
- **Budgets:** Fixes Issue \#2604 [\#2614](https://github.com/consul/consul/pull/2614)
- **Officing:** Officing not to vote [\#2726](https://github.com/consul/consul/pull/2726)
- **Officing:** Officing sidebar menu [\#2725](https://github.com/consul/consul/pull/2725)
- **Homepage:** Homepage cards [\#2693](https://github.com/consul/consul/pull/2693)
- **Homepage:** Adding homepage header and cards seeds [\#2679](https://github.com/consul/consul/pull/2679)
- **Homepage:** Add customization of homepage from admin section [\#2641](https://github.com/consul/consul/pull/2641)
- **Globalization:** Allow admin generated content to be translatable [\#2619](https://github.com/consul/consul/pull/2619)
- **Recommendations:** Debates and proposals recommendations for users [\#2760](https://github.com/consul/consul/pull/2760)
- **Notifications:** Allow author notifications to be moderated [\#2717](https://github.com/consul/consul/pull/2717)
- **Configuration:** Document upload setting [\#2585](https://github.com/consul/consul/pull/2585)
- **Maintenance:** add proposal image on dev\_seeds task [\#2768](https://github.com/consul/consul/pull/2768)
- **Docker:** Add imagemagick package to Docker configuration [\#2655](https://github.com/consul/consul/pull/2655)
- **Design/UX:** Legislation help gif [\#2732](https://github.com/consul/consul/pull/2732)

### Changed

- **Budgets:** Add valuator groups assigned to investments to admin tables & csv export [\#2592](https://github.com/consul/consul/pull/2592)
- **Design/UX:** Adds ballot booths menu on admin [\#2716](https://github.com/consul/consul/pull/2716)
- **Design/UX:** Polls UI [\#2765](https://github.com/consul/consul/pull/2765)
- **Design/UX:** Manager UI [\#2715](https://github.com/consul/consul/pull/2715)
- **Design/UX:** Homepage design [\#2694](https://github.com/consul/consul/pull/2694)
- **Design/UX:** Admin UI [\#2666](https://github.com/consul/consul/pull/2666)
- **Design/UX:** Minor fixes [\#2665](https://github.com/consul/consul/pull/2665)
- **Design/UX:** Homepage layout [\#2663](https://github.com/consul/consul/pull/2663)
- **Design/UX:** Admin form improvements [\#2645](https://github.com/consul/consul/pull/2645)
- **Maintenance:** Regenerate Gemfile.lock [\#2701](https://github.com/consul/consul/pull/2701)
- **Maintenance:** Update Sprockets to fix vulnerability [\#2758](https://github.com/consul/consul/pull/2758)
- **Maintenance:** Split spec common actions support helper [\#2653](https://github.com/consul/consul/pull/2653)
- **Maintenance:** Split admin settings [\#2650](https://github.com/consul/consul/pull/2650)
- **Maintenance:** Update README with production configuration [\#2648](https://github.com/consul/consul/pull/2648)
- **Maintenance:** Remove sitemap generator output when running specs [\#2599](https://github.com/consul/consul/pull/2599)
- **Maintenance:** Avoid db:dev\_seed log print when run from its test [\#2598](https://github.com/consul/consul/pull/2598)
- **Maintenance:** Foundation update [\#2590](https://github.com/consul/consul/pull/2590)
- **Docker:** Docker/docker-compose enhancements [\#2661](https://github.com/consul/consul/pull/2661)

### Fixed

- **Budgets:** Fix valuation heading filters [\#2578](https://github.com/consul/consul/pull/2578)
- **Budgets:** Budgets homepage map fixes [\#2654](https://github.com/consul/consul/pull/2654)
- **Budgets:** Display message in budget's index when there are no budgets [\#2575](https://github.com/consul/consul/pull/2575)
- **Proposals:** Fix validation error when creating proposals without user verification [\#2775](https://github.com/consul/consul/pull/2775)
- **Design/UX:** UI design [\#2733](https://github.com/consul/consul/pull/2733)
- **Design/UX:** A11y [\#2724](https://github.com/consul/consul/pull/2724)
- **Design/UX:** UI design [\#2608](https://github.com/consul/consul/pull/2608)
- **Design/UX:** Fixes admin menu toggle [\#2692](https://github.com/consul/consul/pull/2692)
- **Maintenance:** Fix flaky spec: Budget Investments Show milestones [\#2719](https://github.com/consul/consul/pull/2719)
- **Maintenance:** Fix flaky specs: Votes Debates and Voting comments Update [\#2734](https://github.com/consul/consul/pull/2734)
- **Maintenance:** Fix flaky specs using CKEditor [\#2711](https://github.com/consul/consul/pull/2711)
- **Maintenance:** Fix suggestions being requested with every keystroke [\#2708](https://github.com/consul/consul/pull/2708)
- **Maintenance:** Fix valuation heading filters [\#2702](https://github.com/consul/consul/pull/2702)
- **Maintenance:** Flaky spec: Polls Concerns behaves like notifiable in-app Multiple users commented on my notifiable [\#2699](https://github.com/consul/consul/pull/2699)
- **Maintenance:** Fix flaky spec: Proposals Voting Voting proposals on behalf of someone in show view [\#2697](https://github.com/consul/consul/pull/2697)
- **Maintenance:** Fix flaky spec: Admin budgets Manage groups and headings Create group [\#2696](https://github.com/consul/consul/pull/2696)
- **Maintenance:** Fix flaky specs: Emails Budgets Selected/Unselected investment [\#2695](https://github.com/consul/consul/pull/2695)
- **Maintenance:** Fix flaky specs: Officing Results Add/Edit results [\#2712](https://github.com/consul/consul/pull/2712)
- **Maintenance:** Add issue template [\#2722](https://github.com/consul/consul/pull/2722)
- **Users activity:** Deal gracefully with hidden followable in my activity [\#2752](https://github.com/consul/consul/pull/2752)
- **Recommendations:** Deal gracefully with recommendations of hidden proposals [\#2751](https://github.com/consul/consul/pull/2751)
- **Maps:** Fix MapLocation json\_data to return mappable ids [\#2613](https://github.com/consul/consul/pull/2613)

## [0.15.0](https://github.com/consul/consul/compare/v0.14...v0.15) - 2018-05-23

### Added

- **Budgets:** Show 'See Results' button in budget admin panel [\#2632](https://github.com/consul/consul/pull/2632)
- **Budgets:** Add valuator groups  assigned to investments to admin tables & csv export [\#2592](https://github.com/consul/consul/pull/2592)
- **Budgets:** Add Valuator Group name validation & related specs [\#2576](https://github.com/consul/consul/pull/2576)
- **Budgets:** Display message in budget's index when there are no budgets [\#2575](https://github.com/consul/consul/pull/2575)
- **Budgets:** Allow supporting investments on more than one heading per group [\#2546](https://github.com/consul/consul/pull/2546)
- **Budgets:** User segment for users that haven't supported in budget [\#2540](https://github.com/consul/consul/pull/2540)
- **Budgets:** Allow Budget Group names to be edited [\#2504](https://github.com/consul/consul/pull/2504)
- **Budgets:** Add valuator groups [\#2510](https://github.com/consul/consul/pull/2510)
- **Budgets:** Add column show to valuators [\#2342](https://github.com/consul/consul/pull/2342)
- **Globalization:** Allow admin generated content to be translatable [\#2619](https://github.com/consul/consul/pull/2619)
- **Globalization:** New Crowdin translations [\#2572](https://github.com/consul/consul/pull/2572)
- **Notifications:** Extend notifications to be marked as read or unread [\#2549](https://github.com/consul/consul/pull/2549)
- **Notifications:** Let users mark Notifications as read [\#2478](https://github.com/consul/consul/issues/2478)
- **Accounts:** Admin users [\#2538](https://github.com/consul/consul/pull/2538)
- **Configuration:** Document upload setting [\#2585](https://github.com/consul/consul/pull/2585)
- **Configuration:** Added setting on admin to skip user verification [\#2399](https://github.com/consul/consul/pull/2399)
- **Management:** Let managers reset user's password [\#2548](https://github.com/consul/consul/pull/2548)
- **Design:** View mode selector on lists [\#2509](https://github.com/consul/consul/issues/2509)
- **Maintenance:** Make config.time\_zone configurable at secrets.yml [\#2468](https://github.com/consul/consul/pull/2468)
- **Maintenance:** Include Node.js as requirement on README [\#2486](https://github.com/consul/consul/pull/2486)
- **Maintenance:** Add Node.js as requirement on README \(spanish\) [\#2550](https://github.com/consul/consul/pull/2550)

### Changed

- **Budgets:** Display unfeasibility explanation only when valuation has finished [\#2570](https://github.com/consul/consul/pull/2570)
- **Budgets:** Admin budget investment info [\#2539](https://github.com/consul/consul/pull/2539)
- **Budgets:** Restrict valuators access to edit/valute only on valuating phase [\#2535](https://github.com/consul/consul/pull/2535)
- **Budgets:** Valuators cannot reopen finished valuations [\#2518](https://github.com/consul/consul/pull/2518)
- **Budgets:** Heading link on budgets message [\#2528](https://github.com/consul/consul/pull/2528)
- **Newsletters:** Admin newsletter email refactor [\#2474](https://github.com/consul/consul/pull/2474)
- **Newsletters:** Admin emails list download [\#2466](https://github.com/consul/consul/pull/2466)
- **Newsletters:** Admin newsletter emails [\#2462](https://github.com/consul/consul/pull/2462)
- **Maintenance:** Migration from PhantomJS to Headless Chrome [\#2534](https://github.com/consul/consul/pull/2534)
- **Maintenance:** Update rubocop gem from 0.53.0 to 0.54.0 [\#2574](https://github.com/consul/consul/pull/2574)
- **Maintenance:** Update rails-html-sanitizer gem version to 1.0.4 [\#2568](https://github.com/consul/consul/pull/2568)
- **Maintenance:** Improve README code syntax [\#2561](https://github.com/consul/consul/pull/2561)
- **Maintenance:** Improve Github's Pull Request Template file [\#2515](https://github.com/consul/consul/pull/2515)
- **Maintenance:** Remove sitemap generator output when running specs [\#2599](https://github.com/consul/consul/pull/2599)
- **Maintenance:** Avoid db:dev\_seed log print when run from its test [\#2598](https://github.com/consul/consul/pull/2598)
- **Maintenance:** Update loofah gem to 2.2.1 version [\#2545](https://github.com/consul/consul/pull/2545)
- **Maintenance:** Rubocop & rubocop-rspec gem & config updates [\#2524](https://github.com/consul/consul/pull/2524)

### Fixed

- **Budgets:** Fix valuation heading filters [\#2578](https://github.com/consul/consul/pull/2578)
- **Budgets:** Fixes budgets ui for all phases [\#2537](https://github.com/consul/consul/pull/2537)
- **Budgets:** Fixes Issue \#2604 [\#2614](https://github.com/consul/consul/pull/2614)
- **Maps:** Fix MapLocation json\_data to return mappable ids [\#2613](https://github.com/consul/consul/pull/2613)
- **Accounts:** Fix to change email address from my account [\#2569](https://github.com/consul/consul/pull/2569)
- **Social share:** Fixes social share buttons [\#2525](https://github.com/consul/consul/pull/2525)
- **Newsletters:** Fixed how newsletters controller and mailer handle recipients [\#2492](https://github.com/consul/consul/pull/2492)
- **Newsletters:** Fix UserSegment feasible and undecided investment authors [\#2491](https://github.com/consul/consul/pull/2491)
- **Newsletters:** Remove empty emails from user segment [\#usages](usages)
- **Design:** Mode view [\#2567](https://github.com/consul/consul/pull/2567)
- **Design:** Minor fixes [\#2566](https://github.com/consul/consul/pull/2566)
- **Design:** Improve Documents list [\#2490](https://github.com/consul/consul/pull/2490)
- **Design:** UI fixes [\#2489](https://github.com/consul/consul/pull/2489)
- **Design:** Cleans legislation proposals [\#2527](https://github.com/consul/consul/pull/2527)
- **Design:** Design minor fixes [\#2465](https://github.com/consul/consul/pull/2465)
- **Design:** Help text [\#2452](https://github.com/consul/consul/pull/2452)
- **Maintenance:** Fix routes deprecation warning for `to:` usage [\#2560](https://github.com/consul/consul/pull/2560)
- **Maintenance:** Fix date parsing to take the TimeZone in account  [\#2559](https://github.com/consul/consul/pull/2559)
- **Maintenance:** Fix `rake db:dev\_seed` task flaky spec [\#2522](https://github.com/consul/consul/pull/2522)
- **Maintenance:** Fix Email Spec comment random failures [\#2506](https://github.com/consul/consul/pull/2506)
- **Maintenance:** Fix flaky spec: Residence Assigned officers Error [\#2458](https://github.com/consul/consul/pull/2458)
- **Maintenance:** Fix for flaky spec in Officing spec test file [\#2543](https://github.com/consul/consul/pull/2543)
- **Maintenance:** Fix Flaky spec: Moderate debates Hide [\#2542](https://github.com/consul/consul/pull/2542)
- **Maintenance:** Fix flaky spec: random investments order scenario [\#2536](https://github.com/consul/consul/pull/2536)
- **Maintenance:** Fixed flaky spec: missing comment on legislation annotation [\#2455](https://github.com/consul/consul/pull/2455)
- **Maintenance:** Fix flaky spec: random investments order scenario  [\#2454](https://github.com/consul/consul/pull/2454)
- **Maintenance:** Fix flaky spec: users without email should not receive emails [\#2453](https://github.com/consul/consul/pull/2453)
- **Maintenance:** Flaky spec fix: Debates Show: "Back" link directs to previous page [\#2513](https://github.com/consul/consul/pull/2513)
- **Maintenance:** Fix Exception in home page [\#2621](https://github.com/consul/consul/issues/2621)
- **Maintenance:** Fix for budget's index when there are no budgets [\#2562](https://github.com/consul/consul/issues/2562)
- **Maintenance:** Fix menu highlighted in admin section [\#2556](https://github.com/consul/consul/issues/2556)

## [0.14.0](https://github.com/consul/consul/compare/v0.13...v0.14) - 2018-03-08

### Added

- Admin newsletter emails [\#2462](https://github.com/consul/consul/pull/2462)
- Admin emails list download [\#2466](https://github.com/consul/consul/pull/2466)
- Alert message when a user deletes an investment project from "My activity" [\#2385](https://github.com/consul/consul/pull/2385)
- Missing polls button on help page [\#2452](https://github.com/consul/consul/pull/2452)
- New legislation processes section on help page [\#2452](https://github.com/consul/consul/pull/2452)
- Docs\(readme\): Include Node.js as requirement [\#2486](https://github.com/consul/consul/pull/2486)

### Changed

- Improved Document lists [\#2490](https://github.com/consul/consul/pull/2490)
- Valuators cannot reopen finished valuations [\#2518](https://github.com/consul/consul/pull/2518)
- Show investment links only on phase balloting or later [\#2386](https://github.com/consul/consul/pull/2386)
- Improve Github's Pull Request Template file [\#2515](https://github.com/consul/consul/pull/2515)
- List Budget Investment's milestones ordered by publication date [\#2429](https://github.com/consul/consul/issues/2429)
- Admin newsletter email refactor [\#2474](https://github.com/consul/consul/pull/2474)
- Budgets map improvements [\#2552](https://github.com/consul/consul/pull/2552)

### Deprecated

- Totally remove investment's internal_comments [\#2406](https://github.com/consul/consul/pull/2406)

### Fixed

- Fixes social share buttons: [\#2525](https://github.com/consul/consul/pull/2525)
- Heading link on budgets message: [\#2528](https://github.com/consul/consul/pull/2528)
- Improve spec boot time and clean up of test logs [\#2444](https://github.com/consul/consul/pull/2444)
- Use user locale instead of default locale to format currencies [\#2443](https://github.com/consul/consul/pull/2443)
- Flaky spec: random investments order scenario [\#2454](https://github.com/consul/consul/pull/2454)
- Flaky spec: users without email should not receive emails [\#2453](https://github.com/consul/consul/pull/2453)
- Flaky spec: missing comment on legislation annotation [\#2455](https://github.com/consul/consul/pull/2455)
- Flaky spec: Residence Assigned officers error [\#2458](https://github.com/consul/consul/pull/2458)
- Flaky spec fix: Debates Show: "Back" link directs to previous page [\#2513](https://github.com/consul/consul/pull/2513)
- Flaky spec fix: Email Spec comment random failures [\#2506](https://github.com/consul/consul/pull/2506)
- Expire Coveralls badge cache [\#2445](https://github.com/consul/consul/pull/2445)
- Fixed how newsletters controller and mailer handle recipients [\#2492](https://github.com/consul/consul/pull/2492)
- Fix UserSegment feasible and undecided investment authors [\#2491](https://github.com/consul/consul/pull/2491)
- Remove empty emails from user segment usages [\#2516](https://github.com/consul/consul/pull/2516)
- Clean html and scss legislation proposals: [\#2527](https://github.com/consul/consul/pull/2527)
- UI fixes [\#2489](https://github.com/consul/consul/pull/2489) and [\#2465](https://github.com/consul/consul/pull/2465)

## [0.13.0](https://github.com/consul/consul/compare/v0.12...v0.13) - 2018-02-05

### Added

- Added Drafting phase to Budgets [\#2285](https://github.com/consul/consul/pull/2285)
- Added 'Publish investments price' phase to Budgets [\#2296](https://github.com/consul/consul/pull/2296)
- Allow admins to destroy budgets without investments [\#2283](https://github.com/consul/consul/pull/2283)
- Added CSV download link to budget_investments [\#2147](https://github.com/consul/consul/pull/2147)
- Added actions to edit and delete a budget's headings [\#1917](https://github.com/consul/consul/pull/1917)
- Allow Budget Investments to be Related to other content [\#2311](https://github.com/consul/consul/pull/2311)
- New Budget::Phase model to add dates, enabling and more [\#2323](https://github.com/consul/consul/pull/2323)
- Add optional Guide page to help users decide between Proposal & Investment creation [\#2343](https://github.com/consul/consul/pull/2343)
- Add advanced search menu to investments list [\#2142](https://github.com/consul/consul/pull/2142)
- Allow admins to edit Budget phases [\#2353](https://github.com/consul/consul/pull/2353)
- Budget new Information phase [\#2349](https://github.com/consul/consul/pull/2349)
- Add search & sorting options to Admin's Budget Investment list [\#2378](https://github.com/consul/consul/pull/2378)
- Added internal valuation comment thread to replace internal_comments [\#2403](https://github.com/consul/consul/pull/2403)
- Added rubocop-rspec gem, enabled cops one by one fixing offenses.
- Added Capistrano task to automate maintenance mode [\#1932](https://github.com/consul/consul/pull/1932)

### Changed

- Display proposal and investment image when sharing in social networks [\#2202](https://github.com/consul/consul/pull/2202)
- Redirect admin to budget lists after edit [\#2284](https://github.com/consul/consul/pull/2284)
- Improve budget investment form [\#2280](https://github.com/consul/consul/pull/2280)
- Prevent edition of investments if budget is in the final phase [\#2223](https://github.com/consul/consul/pull/2223)
- Design Improvements [\#2327](https://github.com/consul/consul/pull/2327)
- Change concept of current budget to account for multiple budgets [\#2322](https://github.com/consul/consul/pull/2322)
- Investment valuation finished alert [\#2324](https://github.com/consul/consul/pull/2324)
- Finished budgets list order [\#2355](https://github.com/consul/consul/pull/2355)
- Improvements for Admin::Budget::Investment filters [\#2344](https://github.com/consul/consul/pull/2344)
- Advanced filters design [\#2379](https://github.com/consul/consul/pull/2379)
- Order Budget group headings by name [\#2367](https://github.com/consul/consul/pull/2367)
- Show only current budget tags in admin budget page [\#2387](https://github.com/consul/consul/pull/2387)
- Correctly show finished budgets at budget index [\#2369](https://github.com/consul/consul/pull/2369)
- Multiple Budgets UI improvements [\#2297](https://github.com/consul/consul/pull/2297)
- Improved budget heading names at dropdowns [\#2373](https://github.com/consul/consul/pull/2373)
- Improved Admin list of budget headings [\#2370](https://github.com/consul/consul/pull/2370)
- Remove usage of Investment's internal_comments [\#2404](https://github.com/consul/consul/pull/2404)
- Made English the default app locale [\#2371](https://github.com/consul/consul/pull/2371)
- Improve texts of help page [\#2405](https://github.com/consul/consul/pull/2405)
- Show error message when relating content to itself [\#2416](https://github.com/consul/consul/pull/2416)
- Split 'routes.rb' file into multiple small files [\#1908](https://github.com/consul/consul/pull/1908)
- Removed legislation section arrows and duplicate html tag thanks to [xarlybovi](https://github.com/xarlybovi) [\#1704](https://github.com/consul/consul/issues/1704)
- Updated multiple minor & patch gem versions thanks to [Depfu](https://depfu.com)
- Clean up Travis logs [\#2357](https://github.com/consul/consul/pull/2357)
- Updated translations to other languages from Crowdin contributions [\#2347](https://github.com/consul/consul/pull/2347) especial mention to @ferraniki for 100% Valencian translation!
- Updated rubocop version and ignored all cops by default

### Deprecated

- Budget's `description_*` columns will be erased from database in next release. Please run rake task `budgets:phases:generate_missing` to migrate them. Details at Warning section of [\#2323](https://github.com/consul/consul/pull/2323)
- Budget::Investment's `internal_comments` attribute usage was removed, because of [\#2403](https://github.com/consul/consul/pull/2403), run rake task `investments:internal_comments:migrate_to_thread` to migrate existing values to the new internal comments thread. In next release database column will be removed.

### Removed

- Spending Proposals urls from sitemap, that model is getting entirely deprecated soon.

### Fixed

- Fix Budget Investment's milestones order [\#2431](https://github.com/consul/consul/pull/2431)
- Only change budget slugs if its on draft phase [\#2434](https://github.com/consul/consul/pull/2434)
- Fixed an internal bug that allowed users to remove documents from other user's Proposals & Investments [\#97ec5511](https://github.com/consul/consul/commit/97ec551178591ea9f59744f53c7aadcaad5e679a#diff-bc7e874fa3fd44e4b6f941b434d1d921)
- Fixed deprecation warning in specs [\#2293](https://github.com/consul/consul/pull/2293)
- Fix social images meta tags [\#2153](https://github.com/consul/consul/pull/2153)
- Non translated strings & typos [\#2279](https://github.com/consul/consul/pull/2279)
- Links to hidden comments on admin & moderation [\#2395](https://github.com/consul/consul/pull/2395)

### Security

- Upgraded Paperclip version up to 5.2.1 to fix security problem [\#2393](https://github.com/consul/consul/pull/2393)
- Upgraded nokogiri: 1.8.1 → 1.8.2 [\#2413](https://github.com/consul/consul/pull/2413)

## [0.12.0](https://github.com/consul/consul/compare/v0.11...v0.12) - 2018-01-03

### Added

- Added Images to Budget Investment's Milestones [\#2186](https://github.com/consul/consul/pull/2186)
- Added Documents to Budget Investment's Milestones [\#2191](https://github.com/consul/consul/pull/2191)
- Added Publication Date Budget Investment's Milestones [\#2188](https://github.com/consul/consul/pull/2188)
- New setting `feature.allow_images` to allow upload and show images for both (proposals and budget investment projects). Set it manually through console with `Setting['feature.allow_images'] = true`
- Related Content feature. Now Debates & Proposals can be related [\#1164](https://github.com/consul/consul/issues/1164)
- Map validations [\#2207](https://github.com/consul/consul/pull/2207)
- Added spec for 'rake db:dev_seed' task [\#2201](https://github.com/consul/consul/pull/2201)
- Adds timestamps to polls [\#2180](https://github.com/consul/consul/pull/2180) (Run `rake polls:initialize_timestamps` to initialize attributes created_at and updated_at with the current time for all existing polls, or manually through console set correct values)

### Changed

- Some general Design improvements [\#2170](https://github.com/consul/consul/pull/2170) and [\#2198](https://github.com/consul/consul/pull/2198)
- Improved Communities design [\#1904](https://github.com/consul/consul/pull/1904)
- Made Milestones description required & hided title usage [\#2195](https://github.com/consul/consul/pull/2195)
- Improved generic error message [\#2217](https://github.com/consul/consul/pull/2217)
- Improved Sitemap for SEO [\#2215](https://github.com/consul/consul/pull/2215)

### Fixed

- Notifications for hidden resources [\#2172](https://github.com/consul/consul/pull/2172)
- Notifications exceptions [\#2187](https://github.com/consul/consul/pull/2187)
- Fixed map location update [\#2213](https://github.com/consul/consul/pull/2213)

## [0.11.0](https://github.com/consul/consul/compare/v0.10...v0.11) - 2017-12-05

### Added

- Allow social media image meta tags to be overwritten [\#1756](https://github.com/consul/consul/pull/1756) and [\#2153](https://github.com/consul/consul/pull/2153)
- Allow users to verify their account against a local Census [\#1752](https://github.com/consul/consul/pull/1752)
- Make Proposals & Budgets Investments followable by users [\#1727](https://github.com/consul/consul/pull/1727)
- Show user followable activity on public user page [\#1750](https://github.com/consul/consul/pull/1750)
- Add Budget results view & table [\#1748](https://github.com/consul/consul/pull/1748)
- Improved Budget winners calculations [\#1738](https://github.com/consul/consul/pull/1738)
- Allow Documents to be uploaded to Proposals and Budget Investments [\#1809](https://github.com/consul/consul/pull/1809)
- Allow Communities creation on Proposals and Budget Investments (Run rake task 'communities:associate_community') [\#1815](https://github.com/consul/consul/pull/1815) and [\#1833](https://github.com/consul/consul/pull/1833)
- Allow user to geolocate Proposals and Budget Investments on a map [\#1864](https://github.com/consul/consul/pull/1864)
- Legislation Process Proposals [\#1906](https://github.com/consul/consul/pull/1906)
- Autocomplete user tags [\#1905](https://github.com/consul/consul/pull/1905)
- GraphQL API docs [\#1763](https://github.com/consul/consul/pull/1763)
- Show recommended proposals and debates to users based in their interests [\#1824](https://github.com/consul/consul/pull/1824)
- Allow images & videos to be added to Poll questions [\#1835](https://github.com/consul/consul/pull/1835) and [\#1915](https://github.com/consul/consul/pull/1915)
- Add Poll Shifts, to soon replace Poll OfficerAssignments usage entirely (for now just partially)
- Added dropdown menu for advanced users [\#1761](https://github.com/consul/consul/pull/1761)
- Help text headers and footers [\#1807](https://github.com/consul/consul/pull/1807)
- Added a couple of steps for linux installation guidelines [\#1846](https://github.com/consul/consul/pull/1846)
- Added TotalResult model, to replace Poll::FinalRecount [\#1866](https://github.com/consul/consul/pull/1866) and [\#1885](https://github.com/consul/consul/pull/1885)
- Preview Budget Results by admins [\#1923](https://github.com/consul/consul/pull/1923)
- Added comments to Polls [\#1961](https://github.com/consul/consul/pull/1961)
- Added images & videos to Polls [\#1990](https://github.com/consul/consul/pull/1990) and [\#1989](https://github.com/consul/consul/pull/1989)
- Poll Answers are orderable now [\#2037](https://github.com/consul/consul/pull/2037)
- Poll Booth Assigment management [\#2087](https://github.com/consul/consul/pull/2087)
- Legislation processes documents [\#2084](https://github.com/consul/consul/pull/2084)
- Poll results [\#2082](https://github.com/consul/consul/pull/2082)
- Poll stats [\#2075](https://github.com/consul/consul/pull/2075)
- Poll stats on admin panel [\#2102](https://github.com/consul/consul/pull/2102)
- Added investment user tags admin interface [\#2068](https://github.com/consul/consul/pull/2068)
- Added Poll comments to GraphQL API [\#2148](https://github.com/consul/consul/pull/2148)
- Added option to unassign Valuator role [\#2110](https://github.com/consul/consul/pull/2110)
- Added search by name/email on several Admin sections [\#2105](https://github.com/consul/consul/pull/2105)
- Added Docker support [\#2127](https://github.com/consul/consul/pull/2127) and [Docker documentation](https://consul_docs.gitbooks.io/docs/content/en/getting_started/docker.html)
- Added population restriction validation on Budget Headings [\#2115](https://github.com/consul/consul/pull/2115)
- Added a `/consul.json` route that returns installation details (current release version and feature flags status) for a future dashboard app [\#2164](https://github.com/consul/consul/pull/2164)

### Changed

- Gem versions locked & cleanup [\#1730](https://github.com/consul/consul/pull/1730)
- Upgraded many minor versions [\#1747](https://github.com/consul/consul/pull/1747)
- Rails 4.2.10 [\#2128](https://github.com/consul/consul/pull/2128)
- Updated Code of Conduct to use contributor covenant 1.4  [\#1733](https://github.com/consul/consul/pull/1733)
- Improved consistency to all "Go back" buttons [\#1770](https://github.com/consul/consul/pull/1770)
- New CONSUL brand [\#1808](https://github.com/consul/consul/pull/1808)
- Admin panel redesign [\#1875](https://github.com/consul/consul/pull/1875) and [\#2060](https://github.com/consul/consul/pull/2060)
- Swapped Poll White/Null/Total Results for Poll Recount [\#1963](https://github.com/consul/consul/pull/1963)
- Improved Poll index view [\#1959](https://github.com/consul/consul/pull/1959) and [\#1987](https://github.com/consul/consul/pull/1987)
- Update secrets and deploy secrets example files [\#1966](https://github.com/consul/consul/pull/1966)
- Improved Poll Officer panel features
- Consistency across all admin profiles sections [\#2089](https://github.com/consul/consul/pull/2089)
- Improved dev_seeds with more Poll content [\#2121](https://github.com/consul/consul/pull/2121)
- Comment count now updates live after publishing a new one [\#2090](https://github.com/consul/consul/pull/2090)

### Removed

- Removed Tolk gem usage, we've moved to Crowdin service [\#1729](https://github.com/consul/consul/pull/1729)
- Removed Polls manual recounts (model Poll::FinalRecount) [\#1764](https://github.com/consul/consul/pull/1764)
- Skipped specs for deprecated Spending Proposal model [\#1773](https://github.com/consul/consul/pull/1773)
- Moved Documentation to [docs repository](https://github.com/consul/docs) [\#1861](https://github.com/consul/consul/pull/1861)
- Remove Poll Officer recounts, add Final & Totals votes [\#1919](https://github.com/consul/consul/pull/1919)
- Remove deprecated Poll results models [\#1964](https://github.com/consul/consul/pull/1964)
- Remove deprecated Poll::Question valid_answers attribute & usage [\#2073](https://github.com/consul/consul/pull/2073) and [\#2074](https://github.com/consul/consul/pull/2074)

### Fixed

- Foundation settings stylesheet [\#1766](https://github.com/consul/consul/pull/1766)
- Budget milestone date localization [\#1734](https://github.com/consul/consul/pull/1734)
- Return datetime format for en locale [\#1795](https://github.com/consul/consul/pull/1795)
- Show bottom proposals button only if proposals exists [\#1798](https://github.com/consul/consul/pull/1798)
- Check SMS verification in a more consistent way [\#1832](https://github.com/consul/consul/pull/1832)
- Allow only YouTube/Vimeo URLs on 'video_url' attributes [\#1854](https://github.com/consul/consul/pull/1854)
- Remove empty comments html [\#1862](https://github.com/consul/consul/pull/1862)
- Fixed admin/poll routing errors [\#1863](https://github.com/consul/consul/pull/1863)
- Display datepicker arrows [\#1869](https://github.com/consul/consul/pull/1869)
- Validate presence poll presence on Poll::Question creation [\#1868](https://github.com/consul/consul/pull/1868)
- Switch flag/unflag buttons on use via ajax [\#1883](https://github.com/consul/consul/pull/1883)
- Flaky specs fixed [\#1888](https://github.com/consul/consul/pull/1888)
- Fixed link back from moderation dashboard to root_path [\#2132](https://github.com/consul/consul/pull/2132)
- Fixed Budget random pagination order [\#2131](https://github.com/consul/consul/pull/2131)
- Fixed `direct_messages_max_per_day` set to nil [\#2100](https://github.com/consul/consul/pull/2100)
- Fixed notification link error when someone commented a Topic [\#2094](https://github.com/consul/consul/pull/2094)
- Lots of small UI/UX/SEO/SEM improvements

## [0.10.0](https://github.com/consul/consul/compare/v0.9...v0.10) - 2017-07-05

### Added

- Milestones on Budget Investment's
- Feature flag to enable/disable Legislative Processes
- Locale site pages customization
- Incompatible investments

### Changed

- Localization files reorganization. Check migration instruction at [Release 0.10](https://github.com/consul/consul/releases/tag/v0.10)
- Rails 4.2.9

## [0.9.0](https://github.com/consul/consul/compare/v0.8...v0.9) - 2017-06-15

### Added

- Budgets
- Basic polls
- Collaborative legistlation
- Custom pages
- GraphQL API
- Improved admin section

### Changed

- Improved admin section
- Rails 4.2.8
- Ruby 2.3.2

### Deprecated

- SpendingProposals are deprecated now in favor of Budgets

### Fixed

- CKEditor locale compilation fixed
- Fixed bugs in mobile layouts

## [0.8.0](https://github.com/consul/consul/compare/v0.7...v0.8)- 2016-07-21

### Added

- Support for customization schema, vía specific custom files, assets and folders

### Changed

- Rails 4.2.7
- Ruby 2.3.1

### Fixed

- Fixed bug causing errors on user deletion

## 0.7.0 - 2016-04-25

### Added

- Debates
- Proposals
- Basic Spending Proposals

### Changed

- Rails 4.2.6
- Ruby 2.2.3

[Unreleased]: https://github.com/consul/consul/compare/1.1.0...consul:master
[1.1.0]: https://github.com/consul/consul/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/consul/consul/compare/1.0.0-beta...1.0.0
[1.0.0-beta]: https://github.com/consul/consul/compare/v0.19...1.0.0-beta
[0.19.0]: https://github.com/consul/consul/compare/v0.18...v.019
[0.18.0]: https://github.com/consul/consul/compare/v0.17...v.018
[0.17.0]: https://github.com/consul/consul/compare/v0.16...v.017
[0.16.0]: https://github.com/consul/consul/compare/v0.15...v.016
[0.15.0]: https://github.com/consul/consul/compare/v0.14...v0.15
[0.14.0]: https://github.com/consul/consul/compare/v0.13...v0.14
[0.13.0]: https://github.com/consul/consul/compare/v0.12...v0.13
[0.12.0]: https://github.com/consul/consul/compare/v0.11...v0.12
[0.11.0]: https://github.com/consul/consul/compare/v0.10...v0.11
[0.10.0]: https://github.com/consul/consul/compare/v0.9...v0.10
[0.9.0]: https://github.com/consul/consul/compare/v0.8...v0.9
[0.8.0]: https://github.com/consul/consul/compare/v0.7...v0.8
