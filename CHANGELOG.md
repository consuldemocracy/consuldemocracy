# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.16.0](https://github.com/consul/consul/compare/v0.15...v0.16) - 2018-07-16

### Added
- **Budgets:** Budgets investment show messages https://github.com/consul/consul/pull/2766
- **Budgets:** Add Valuator Group name validation & related specs https://github.com/consul/consul/pull/2576
- **Budgets:** Investment milestone's project status https://github.com/consul/consul/pull/2706
- **Budgets:** Budget statuses https://github.com/consul/consul/pull/2705
- **Budgets:** Display only selected budget investmests in "Publishing prices" phase https://github.com/consul/consul/pull/2657
- **Budgets:** Budgets see results https://github.com/consul/consul/pull/2620
- **Budgets:** Show 'See Results' button in budget admin panel https://github.com/consul/consul/pull/2632
- **Budgets:** Adds message to selected budget investments https://github.com/consul/consul/pull/2622
- **Budgets:** Fixes Issue \#2604 https://github.com/consul/consul/pull/2614
- **Officing:** Officing not to vote https://github.com/consul/consul/pull/2726
- **Officing:** Officing sidebar menu https://github.com/consul/consul/pull/2725
- **Homepage:** Homepage cards https://github.com/consul/consul/pull/2693
- **Homepage:** Adding homepage header and cards seeds https://github.com/consul/consul/pull/2679
- **Homepage:** Add customization of homepage from admin section https://github.com/consul/consul/pull/2641
- **Globalization:** Allow admin generated content to be translatable https://github.com/consul/consul/pull/2619
- **Recommendations:** Debates and proposals recommendations for users https://github.com/consul/consul/pull/2760
- **Notifications:** Allow author notifications to be moderated https://github.com/consul/consul/pull/2717
- **Configuration:** Document upload setting https://github.com/consul/consul/pull/2585
- **Maintenance:** add proposal image on dev\_seeds task https://github.com/consul/consul/pull/2768
- **Docker:** Add imagemagick package to Docker configuration https://github.com/consul/consul/pull/2655
- **Design/UX:** Legislation help gif https://github.com/consul/consul/pull/2732

### Changed
- **Budgets:** Add valuator groups assigned to investments to admin tables & csv export https://github.com/consul/consul/pull/2592
- **Design/UX:** Adds ballot booths menu on admin https://github.com/consul/consul/pull/2716
- **Design/UX:** Polls UI https://github.com/consul/consul/pull/2765
- **Design/UX:** Manager UI https://github.com/consul/consul/pull/2715
- **Design/UX:** Homepage design https://github.com/consul/consul/pull/2694
- **Design/UX:** Admin UI https://github.com/consul/consul/pull/2666
- **Design/UX:** Minor fixes https://github.com/consul/consul/pull/2665
- **Design/UX:** Homepage layout https://github.com/consul/consul/pull/2663
- **Design/UX:** Admin form improvements https://github.com/consul/consul/pull/2645
- **Maintenance:** Regenerate Gemfile.lock https://github.com/consul/consul/pull/2701
- **Maintenance:** Update Sprockets to fix vulnerability https://github.com/consul/consul/pull/2758
- **Maintenance:** Split spec common actions support helper https://github.com/consul/consul/pull/2653
- **Maintenance:** Split admin settings https://github.com/consul/consul/pull/2650
- **Maintenance:** Update README with production configuration https://github.com/consul/consul/pull/2648
- **Maintenance:** Remove sitemap generator output when running specs https://github.com/consul/consul/pull/2599
- **Maintenance:** Avoid db:dev\_seed log print when run from its test https://github.com/consul/consul/pull/2598
- **Maintenance:** Foundation update https://github.com/consul/consul/pull/2590
- **Docker:** Docker/docker-compose enhancements https://github.com/consul/consul/pull/2661

### Fixed
- **Budgets:** Fix valuation heading filters https://github.com/consul/consul/pull/2578
- **Budgets:** Budgets homepage map fixes https://github.com/consul/consul/pull/2654
- **Budgets:** Display message in budget's index when there are no budgets https://github.com/consul/consul/pull/2575
- **Proposals:** Fix validation error when creating proposals without user verification https://github.com/consul/consul/pull/2775
- **Design/UX:** UI design https://github.com/consul/consul/pull/2733
- **Design/UX:** A11y https://github.com/consul/consul/pull/2724
- **Design/UX:** UI design https://github.com/consul/consul/pull/2608
- **Design/UX:** Fixes admin menu toggle https://github.com/consul/consul/pull/2692
- **Maintenance:** Fix flaky spec: Budget Investments Show milestones https://github.com/consul/consul/pull/2719
- **Maintenance:** Fix flaky specs: Votes Debates and Voting comments Update https://github.com/consul/consul/pull/2734
- **Maintenance:** Fix flaky specs using CKEditor https://github.com/consul/consul/pull/2711
- **Maintenance:** Fix suggestions being requested with every keystroke https://github.com/consul/consul/pull/2708
- **Maintenance:** Fix valuation heading filters https://github.com/consul/consul/pull/2702
- **Maintenance:** Flaky spec: Polls Concerns behaves like notifiable in-app Multiple users commented on my notifiable https://github.com/consul/consul/pull/2699
- **Maintenance:** Fix flaky spec: Proposals Voting Voting proposals on behalf of someone in show view https://github.com/consul/consul/pull/2697
- **Maintenance:** Fix flaky spec: Admin budgets Manage groups and headings Create group https://github.com/consul/consul/pull/2696
- **Maintenance:** Fix flaky specs: Emails Budgets Selected/Unselected investment https://github.com/consul/consul/pull/2695
- **Maintenance:** Fix flaky specs: Officing Results Add/Edit results https://github.com/consul/consul/pull/2712
- **Maintenance:** Add issue template https://github.com/consul/consul/pull/2722
- **Users activity:** Deal gracefully with hidden followable in my activity https://github.com/consul/consul/pull/2752
- **Recommendations:** Deal gracefully with recommendations of hidden proposals https://github.com/consul/consul/pull/2751
- **Maps:** Fix MapLocation json\_data to return mappable ids https://github.com/consul/consul/pull/2613

## [0.15.0](https://github.com/consul/consul/compare/v0.14...v0.15) - 2018-05-23

### Added
- **Budgets:** Show 'See Results' button in budget admin panel https://github.com/consul/consul/pull/2632
- **Budgets:** Add valuator groups  assigned to investments to admin tables & csv export https://github.com/consul/consul/pull/2592
- **Budgets:** Add Valuator Group name validation & related specs https://github.com/consul/consul/pull/2576
- **Budgets:** Display message in budget's index when there are no budgets https://github.com/consul/consul/pull/2575
- **Budgets:** Allow supporting investments on more than one heading per group https://github.com/consul/consul/pull/2546
- **Budgets:** User segment for users that haven't supported in budget https://github.com/consul/consul/pull/2540
- **Budgets:** Allow Budget Group names to be edited https://github.com/consul/consul/pull/2504
- **Budgets:** Add valuator groups https://github.com/consul/consul/pull/2510
- **Budgets:** Add column show to valuators https://github.com/consul/consul/pull/2342
- **Globalization:** Allow admin generated content to be translatable https://github.com/consul/consul/pull/2619
- **Globalization:** New Crowdin translations https://github.com/consul/consul/pull/2572
- **Notifications:** Extend notifications to be marked as read or unread https://github.com/consul/consul/pull/2549
- **Notifications:** Let users mark Notifications as read https://github.com/consul/consul/issues/2478
- **Accounts:** Admin users https://github.com/consul/consul/pull/2538
- **Configuration:** Document upload setting https://github.com/consul/consul/pull/2585
- **Configuration:** Added setting on admin to skip user verification https://github.com/consul/consul/pull/2399
- **Management:** Let managers reset user's password https://github.com/consul/consul/pull/2548
- **Design:** View mode selector on lists https://github.com/consul/consul/issues/2509
- **Maintenance:** Make config.time\_zone configurable at secrets.yml https://github.com/consul/consul/pull/2468
- **Maintenance:** Include Node.js as requirement on README https://github.com/consul/consul/pull/2486
- **Maintenance:** Add Node.js as requirement on README \(spanish\) https://github.com/consul/consul/pull/2550

### Changed
- **Budgets:** Display unfeasibility explanation only when valuation has finished https://github.com/consul/consul/pull/2570
- **Budgets:** Admin budget investment info https://github.com/consul/consul/pull/2539
- **Budgets:** Restrict valuators access to edit/valute only on valuating phase https://github.com/consul/consul/pull/2535
- **Budgets:** Valuators cannot reopen finished valuations https://github.com/consul/consul/pull/2518
- **Budgets:** Heading link on budgets message https://github.com/consul/consul/pull/2528
- **Newsletters:** Admin newsletter email refactor https://github.com/consul/consul/pull/2474
- **Newsletters:** Admin emails list download https://github.com/consul/consul/pull/2466
- **Newsletters:** Admin newsletter emails https://github.com/consul/consul/pull/2462
- **Maintenance:** Migration from PhantomJS to Headless Chrome https://github.com/consul/consul/pull/2534
- **Maintenance:** Update rubocop gem from 0.53.0 to 0.54.0 https://github.com/consul/consul/pull/2574
- **Maintenance:** Update rails-html-sanitizer gem version to 1.0.4 https://github.com/consul/consul/pull/2568
- **Maintenance:** Improve README code syntax https://github.com/consul/consul/pull/2561
- **Maintenance:** Improve Github's Pull Request Template file https://github.com/consul/consul/pull/2515
- **Maintenance:** Remove sitemap generator output when running specs https://github.com/consul/consul/pull/2599
- **Maintenance:** Avoid db:dev\_seed log print when run from its test https://github.com/consul/consul/pull/2598
- **Maintenance:** Update loofah gem to 2.2.1 version https://github.com/consul/consul/pull/2545
- **Maintenance:** Rubocop & rubocop-rspec gem & config updates https://github.com/consul/consul/pull/2524

### Fixed
- **Budgets:** Fix valuation heading filters https://github.com/consul/consul/pull/2578
- **Budgets:** Fixes budgets ui for all phases https://github.com/consul/consul/pull/2537
- **Budgets:** Fixes Issue \#2604 https://github.com/consul/consul/pull/2614
- **Maps:** Fix MapLocation json\_data to return mappable ids https://github.com/consul/consul/pull/2613
- **Accounts:** Fix to change email address from my account https://github.com/consul/consul/pull/2569
- **Social share:** Fixes social share buttons https://github.com/consul/consul/pull/2525
- **Newsletters:** Fixed how newsletters controller and mailer handle recipients https://github.com/consul/consul/pull/2492
- **Newsletters:** Fix UserSegment feasible and undecided investment authors https://github.com/consul/consul/pull/2491
- **Newsletters:** Remove empty emails from user segment usages
- **Design:** Mode view https://github.com/consul/consul/pull/2567
- **Design:** Minor fixes https://github.com/consul/consul/pull/2566
- **Design:** Improve Documents list https://github.com/consul/consul/pull/2490
- **Design:** UI fixes https://github.com/consul/consul/pull/2489
- **Design:** Cleans legislation proposals https://github.com/consul/consul/pull/2527
- **Design:** Design minor fixes https://github.com/consul/consul/pull/2465
- **Design:** Help text https://github.com/consul/consul/pull/2452
- **Maintenance:** Fix routes deprecation warning for `to:` usage https://github.com/consul/consul/pull/2560
- **Maintenance:** Fix date parsing to take the TimeZone in account  https://github.com/consul/consul/pull/2559
- **Maintenance:** Fix `rake db:dev\_seed` task flaky spec https://github.com/consul/consul/pull/2522
- **Maintenance:** Fix Email Spec comment random failures https://github.com/consul/consul/pull/2506
- **Maintenance:** Fix flaky spec: Residence Assigned officers Error https://github.com/consul/consul/pull/2458
- **Maintenance:** Fix for flaky spec in Officing spec test file https://github.com/consul/consul/pull/2543
- **Maintenance:** Fix Flaky spec: Moderate debates Hide https://github.com/consul/consul/pull/2542
- **Maintenance:** Fix flaky spec: random investments order scenario https://github.com/consul/consul/pull/2536
- **Maintenance:** Fixed flaky spec: missing comment on legislation annotation https://github.com/consul/consul/pull/2455
- **Maintenance:** Fix flaky spec: random investments order scenario  https://github.com/consul/consul/pull/2454
- **Maintenance:** Fix flaky spec: users without email should not receive emails https://github.com/consul/consul/pull/2453
- **Maintenance:** Flaky spec fix: Debates Show: "Back" link directs to previous page https://github.com/consul/consul/pull/2513
- **Maintenance:** Fix Exception in home page https://github.com/consul/consul/issues/2621
- **Maintenance:** Fix for budget's index when there are no budgets https://github.com/consul/consul/issues/2562
- **Maintenance:** Fix menu highlighted in admin section https://github.com/consul/consul/issues/2556

## [0.14.0](https://github.com/consul/consul/compare/v0.13...v0.14) - 2018-03-08

### Added
- Admin newsletter emails https://github.com/consul/consul/pull/2462
- Admin emails list download https://github.com/consul/consul/pull/2466
- Alert message when a user deletes an investment project from "My activity" https://github.com/consul/consul/pull/2385
- Missing polls button on help page https://github.com/consul/consul/pull/2452
- New legislation processes section on help page https://github.com/consul/consul/pull/2452
- Docs\(readme\): Include Node.js as requirement https://github.com/consul/consul/pull/2486

### Changed
- Improved Document lists https://github.com/consul/consul/pull/2490
- Valuators cannot reopen finished valuations https://github.com/consul/consul/pull/2518
- Show investment links only on phase balloting or later https://github.com/consul/consul/pull/2386
- Improve Github's Pull Request Template file https://github.com/consul/consul/pull/2515
- List Budget Investment's milestones ordered by publication date https://github.com/consul/consul/issues/2429
- Admin newsletter email refactor https://github.com/consul/consul/pull/2474
- Budgets map improvements https://github.com/consul/consul/pull/2552

### Deprecated
- Totally remove investment's internal_comments https://github.com/consul/consul/pull/2406

### Fixed
- Fixes social share buttons: https://github.com/consul/consul/pull/2525
- Heading link on budgets message: https://github.com/consul/consul/pull/2528
- Improve spec boot time and clean up of test logs https://github.com/consul/consul/pull/2444
- Use user locale instead of default locale to format currencies https://github.com/consul/consul/pull/2443
- Flaky spec: random investments order scenario https://github.com/consul/consul/pull/2454
- Flaky spec: users without email should not receive emails https://github.com/consul/consul/pull/2453
- Flaky spec: missing comment on legislation annotation https://github.com/consul/consul/pull/2455
- Flaky spec: Residence Assigned officers error https://github.com/consul/consul/pull/2458
- Flaky spec fix: Debates Show: "Back" link directs to previous page https://github.com/consul/consul/pull/2513
- Flaky spec fix: Email Spec comment random failures https://github.com/consul/consul/pull/2506
- Expire Coveralls badge cache https://github.com/consul/consul/pull/2445
- Fixed how newsletters controller and mailer handle recipients https://github.com/consul/consul/pull/2492
- Fix UserSegment feasible and undecided investment authors https://github.com/consul/consul/pull/2491
- Remove empty emails from user segment usages https://github.com/consul/consul/pull/2516
- Clean html and scss legislation proposals: https://github.com/consul/consul/pull/2527
- UI fixes https://github.com/consul/consul/pull/2489 https://github.com/consul/consul/pull/2465

## [0.13.0](https://github.com/consul/consul/compare/v0.12...v0.13) - 2018-02-05

### Added
- Added Drafting phase to Budgets https://github.com/consul/consul/pull/2285
- Added 'Publish investments price' phase to Budgets https://github.com/consul/consul/pull/2296
- Allow admins to destroy budgets without investments https://github.com/consul/consul/pull/2283
- Added CSV download link to budget_investments https://github.com/consul/consul/pull/2147
- Added actions to edit and delete a budget's headings https://github.com/consul/consul/pull/1917
- Allow Budget Investments to be Related to other content https://github.com/consul/consul/pull/2311
- New Budget::Phase model to add dates, enabling and more https://github.com/consul/consul/pull/2323
- Add optional Guide page to help users decide between Proposal & Investment creation https://github.com/consul/consul/pull/2343
- Add advanced search menu to investments list https://github.com/consul/consul/pull/2142
- Allow admins to edit Budget phases https://github.com/consul/consul/pull/2353
- Budget new Information phase https://github.com/consul/consul/pull/2349
- Add search & sorting options to Admin's Budget Investment list https://github.com/consul/consul/pull/2378
- Added internal valuation comment thread to replace internal_comments https://github.com/consul/consul/pull/2403
- Added rubocop-rspec gem, enabled cops one by one fixing offenses.
- Added Capistrano task to automate maintenance mode https://github.com/consul/consul/pull/1932

### Changed
- Display proposal and investment image when sharing in social networks https://github.com/consul/consul/pull/2202
- Redirect admin to budget lists after edit https://github.com/consul/consul/pull/2284
- Improve budget investment form https://github.com/consul/consul/pull/2280
- Prevent edition of investments if budget is in the final phase https://github.com/consul/consul/pull/2223
- Design Improvements https://github.com/consul/consul/pull/2327
- Change concept of current budget to account for multiple budgets https://github.com/consul/consul/pull/2322
- Investment valuation finished alert https://github.com/consul/consul/pull/2324
- Finished budgets list order https://github.com/consul/consul/pull/2355
- Improvements for Admin::Budget::Investment filters https://github.com/consul/consul/pull/2344
- Advanced filters design https://github.com/consul/consul/pull/2379
- Order Budget group headings by name https://github.com/consul/consul/pull/2367
- Show only current budget tags in admin budget page https://github.com/consul/consul/pull/2387
- Correctly show finished budgets at budget index https://github.com/consul/consul/pull/2369
- Multiple Budgets UI improvements https://github.com/consul/consul/pull/2297
- Improved budget heading names at dropdowns https://github.com/consul/consul/pull/2373
- Improved Admin list of budget headings https://github.com/consul/consul/pull/2370
- Remove usage of Investment's internal_comments https://github.com/consul/consul/pull/2404
- Made English the default app locale https://github.com/consul/consul/pull/2371
- Improve texts of help page https://github.com/consul/consul/pull/2405
- Show error message when relating content to itself https://github.com/consul/consul/pull/2416
- Split 'routes.rb' file into multiple small files https://github.com/consul/consul/pull/1908
- Removed legislation section arrows and duplicate html tag thanks to [xarlybovi](https://github.com/xarlybovi) https://github.com/consul/consul/issues/1704
- Updated multiple minor & patch gem versions thanks to [Depfu](https://depfu.com)
- Clean up Travis logs https://github.com/consul/consul/pull/2357
- Updated translations to other languages from Crowdin contributions https://github.com/consul/consul/pull/2347 especial mention to @ferraniki for 100% Valencian translation!
- Updated rubocop version and ignored all cops by default

### Deprecated
- Budget's `description_*` columns will be erased from database in next release. Please run rake task `budgets:phases:generate_missing` to migrate them. Details at Warning section of https://github.com/consul/consul/pull/2323
- Budget::Investment's `internal_comments` attribute usage was removed, because of https://github.com/consul/consul/pull/2403, run rake task `investments:internal_comments:migrate_to_thread` to migrate existing values to the new internal comments thread. In next release database column will be removed.

### Removed
- Spending Proposals urls from sitemap, that model is getting entirely deprecated soon.

### Fixed
- Fix Budget Investment's milestones order https://github.com/consul/consul/pull/2431
- Only change budget slugs if its on draft phase https://github.com/consul/consul/pull/2434
- Fixed an internal bug that allowed users to remove documents from other user's Proposals & Investments https://github.com/consul/consul/commit/97ec551178591ea9f59744f53c7aadcaad5e679a#diff-bc7e874fa3fd44e4b6f941b434d1d921
- Fixed deprecation warning in specs https://github.com/consul/consul/pull/2293
- Fix social images meta tags https://github.com/consul/consul/pull/2153
- Non translated strings & typos https://github.com/consul/consul/pull/2279
- Links to hidden comments on admin & moderation https://github.com/consul/consul/pull/2395

### Security
- Upgraded Paperclip version up to 5.2.1 to fix security problem https://github.com/consul/consul/pull/2393
- Upgraded nokogiri: 1.8.1 → 1.8.2 https://github.com/consul/consul/pull/2413

## [0.12.0](https://github.com/consul/consul/compare/v0.11...v0.12) - 2018-01-03

### Added
- Added Images to Budget Investment's Milestones https://github.com/consul/consul/pull/2186
- Added Documents to Budget Investment's Milestones https://github.com/consul/consul/pull/2191
- Added Publication Date Budget Investment's Milestones https://github.com/consul/consul/pull/2188
- New setting `feature.allow_images` to allow upload and show images for both (proposals and budget investment projects). Set it manually through console with `Setting['feature.allow_images'] = true`
- Related Content feature. Now Debates & Proposals can be related https://github.com/consul/consul/issues/1164
- Map validations https://github.com/consul/consul/pull/2207
- Added spec for 'rake db:dev_seed' task https://github.com/consul/consul/pull/2201
- Adds timestamps to polls https://github.com/consul/consul/pull/2180 (Run `rake polls:initialize_timestamps` to initialize attributes created_at and updated_at with the current time for all existing polls, or manually through console set correct values)

### Changed
- Some general Design improvements https://github.com/consul/consul/pull/2170 https://github.com/consul/consul/pull/2198
- Improved Communities design https://github.com/consul/consul/pull/1904
- Made Milestones description required & hided title usage https://github.com/consul/consul/pull/2195
- Improved generic error message https://github.com/consul/consul/pull/2217
- Improved Sitemap for SEO https://github.com/consul/consul/pull/2215

### Fixed
- Notifications for hidden resources https://github.com/consul/consul/pull/2172
- Notifications exceptions https://github.com/consul/consul/pull/2187
- Fixed map location update https://github.com/consul/consul/pull/2213

## [0.11.0](https://github.com/consul/consul/compare/v0.10...v0.11) - 2017-12-05

### Added
- Allow social media image meta tags to be overwritten https://github.com/consul/consul/pull/1756 & https://github.com/consul/consul/pull/2153
- Allow users to verify their account against a local Census https://github.com/consul/consul/pull/1752
- Make Proposals & Budgets Investments followable by users https://github.com/consul/consul/pull/1727
- Show user followable activity on public user page https://github.com/consul/consul/pull/1750
- Add Budget results view & table https://github.com/consul/consul/pull/1748
- Improved Budget winners calculations https://github.com/consul/consul/pull/1738
- Allow Documents to be uploaded to Proposals and Budget Investments https://github.com/consul/consul/pull/1809
- Allow Communities creation on Proposals and Budget Investments (Run rake task 'communities:associate_community') https://github.com/consul/consul/pull/1815 https://github.com/consul/consul/pull/1833
- Allow user to geolocate Proposals and Budget Investments on a map https://github.com/consul/consul/pull/1864
- Legislation Process Proposals https://github.com/consul/consul/pull/1906
- Autocomplete user tags https://github.com/consul/consul/pull/1905
- GraphQL API docs https://github.com/consul/consul/pull/1763
- Show recommended proposals and debates to users based in their interests https://github.com/consul/consul/pull/1824
- Allow images & videos to be added to Poll questions https://github.com/consul/consul/pull/1835 https://github.com/consul/consul/pull/1915
- Add Poll Shifts, to soon replace Poll OfficerAssignments usage entirely (for now just partially)
- Added dropdown menu for advanced users https://github.com/consul/consul/pull/1761
- Help text headers and footers https://github.com/consul/consul/pull/1807
- Added a couple of steps for linux installation guidelines https://github.com/consul/consul/pull/1846
- Added TotalResult model, to replace Poll::FinalRecount https://github.com/consul/consul/pull/1866 1885
- Preview Budget Results by admins https://github.com/consul/consul/pull/1923
- Added comments to Polls https://github.com/consul/consul/pull/1961
- Added images & videos to Polls https://github.com/consul/consul/pull/1990 https://github.com/consul/consul/pull/1989
- Poll Answers are orderable now https://github.com/consul/consul/pull/2037
- Poll Booth Assigment management https://github.com/consul/consul/pull/2087
- Legislation processes documents https://github.com/consul/consul/pull/2084
- Poll results https://github.com/consul/consul/pull/2082
- Poll stats https://github.com/consul/consul/pull/2075
- Poll stats on admin panel https://github.com/consul/consul/pull/2102
- Added investment user tags admin interface https://github.com/consul/consul/pull/2068
- Added Poll comments to GraphQL API https://github.com/consul/consul/pull/2148
- Added option to unassign Valuator role https://github.com/consul/consul/pull/2110
- Added search by name/email on several Admin sections https://github.com/consul/consul/pull/2105
- Added Docker support https://github.com/consul/consul/pull/2127 & documentation https://consul_docs.gitbooks.io/docs/content/en/getting_started/docker.html
- Added population restriction validation on Budget Headings https://github.com/consul/consul/pull/2115
- Added a `/consul.json` route that returns installation details (current release version and feature flags status) for a future dashboard app https://github.com/consul/consul/pull/2164

### Changed
- Gem versions locked & cleanup https://github.com/consul/consul/pull/1730
- Upgraded many minor versions https://github.com/consul/consul/pull/1747
- Rails 4.2.10 https://github.com/consul/consul/pull/2128
- Updated Code of Conduct to use contributor covenant 1.4  https://github.com/consul/consul/pull/1733
- Improved consistency to all "Go back" buttons https://github.com/consul/consul/pull/1770
- New CONSUL brand https://github.com/consul/consul/pull/1808
- Admin panel redesign https://github.com/consul/consul/pull/1875 https://github.com/consul/consul/pull/2060
- Swapped Poll White/Null/Total Results for Poll Recount https://github.com/consul/consul/pull/1963
- Improved Poll index view https://github.com/consul/consul/pull/1959 https://github.com/consul/consul/pull/1987
- Update secrets and deploy secrets example files https://github.com/consul/consul/pull/1966
- Improved Poll Officer panel features
- Consistency across all admin profiles sections https://github.com/consul/consul/pull/2089
- Improved dev_seeds with more Poll content https://github.com/consul/consul/pull/2121
- Comment count now updates live after publishing a new one https://github.com/consul/consul/pull/2090

### Removed
- Removed Tolk gem usage, we've moved to Crowdin service https://github.com/consul/consul/pull/1729
- Removed Polls manual recounts (model Poll::FinalRecount) https://github.com/consul/consul/pull/1764
- Skipped specs for deprecated Spending Proposal model https://github.com/consul/consul/pull/1773
- Moved Documentation to https://github.com/consul/docs https://github.com/consul/consul/pull/1861
- Remove Poll Officer recounts, add Final & Totals votes https://github.com/consul/consul/pull/1919
- Remove deprecated Poll results models https://github.com/consul/consul/pull/1964
- Remove deprecated Poll::Question valid_answers attribute & usage https://github.com/consul/consul/pull/2073 https://github.com/consul/consul/pull/2074

### Fixed
- Foundation settings stylesheet https://github.com/consul/consul/pull/1766
- Budget milestone date localization https://github.com/consul/consul/pull/1734
- Return datetime format for en locale https://github.com/consul/consul/pull/1795
- Show bottom proposals button only if proposals exists https://github.com/consul/consul/pull/1798
- Check SMS verification in a more consistent way https://github.com/consul/consul/pull/1832
- Allow only YouTube/Vimeo URLs on 'video_url' attributes https://github.com/consul/consul/pull/1854
- Remove empty comments html https://github.com/consul/consul/pull/1862
- Fixed admin/poll routing errors https://github.com/consul/consul/pull/1863
- Display datepicker arrows https://github.com/consul/consul/pull/1869
- Validate presence poll presence on Poll::Question creation https://github.com/consul/consul/pull/1868
- Switch flag/unflag buttons on use via ajax https://github.com/consul/consul/pull/1883
- Flaky specs fixed https://github.com/consul/consul/pull/1888
- Fixed link back from moderation dashboard to root_path https://github.com/consul/consul/pull/2132
- Fixed Budget random pagination order https://github.com/consul/consul/pull/2131
- Fixed `direct_messages_max_per_day` set to nil https://github.com/consul/consul/pull/2100
- Fixed notification link error when someone commented a Topic https://github.com/consul/consul/pull/2094
- Lots of small UI/UX/SEO/SEM improvements

## [0.10.0](https://github.com/consul/consul/compare/v0.9...v0.10) - 2017-07-05
### Added
- Milestones on Budget Investment's
- Feature flag to enable/disable Legislative Processes
- Locale site pages customization
- Incompatible investments

### Changed
- Localization files reorganization. Check migration instruction at https://github.com/consul/consul/releases/tag/v0.10
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

## [0.7.0] - 2016-04-25
### Added
- Debates
- Proposals
- Basic Spending Proposals

### Changed
- Rails 4.2.6
- Ruby 2.2.3

[Unreleased]: https://github.com/consul/consul/compare/v0.16...consul:master
[0.16.0]: https://github.com/consul/consul/compare/v0.15...v.016
[0.15.0]: https://github.com/consul/consul/compare/v0.14...v0.15
[0.14.0]: https://github.com/consul/consul/compare/v0.13...v0.14
[0.13.0]: https://github.com/consul/consul/compare/v0.12...v0.13
[0.12.0]: https://github.com/consul/consul/compare/v0.11...v0.12
[0.11.0]: https://github.com/consul/consul/compare/v0.10...v0.11
[0.10.0]: https://github.com/consul/consul/compare/v0.9...v0.10
[0.9.0]: https://github.com/consul/consul/compare/v0.8...v0.9
[0.8.0]: https://github.com/consul/consul/compare/v0.7...v0.8
