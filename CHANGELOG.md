# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/consul/consul/compare/v0.10...consul:master)

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

[Unreleased]: https://github.com/consul/consul/compare/v0.10...consul:master
[0.10.0]: https://github.com/consul/consul/compare/v0.9...v0.10
[0.9.0]: https://github.com/consul/consul/compare/v0.8...v0.9
[0.8.0]: https://github.com/consul/consul/compare/v0.7...v0.8
