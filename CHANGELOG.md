# Changelog

# [2.0.0] 2020-09-16

## Interface change

* `Report#wikitext_with_header` has been removed. This was undocumented,
  and only used internally, so should not be a breaking change, but if
  anything *was* using it, that will now break loudly (but, usefully,
  should also break very early.)

## Enhancements

* A {{PositionHolderHistory}} template can now also be added to items
  representing single-member constituencies, to see the history of
  representatives for that seat.

# [1.11.0] 2020-09-14

## Enhancements

* Wikidata now has a new {{QB}} template to link to _both_ an Item and
  its Talk page. As the PositionHolderHistory template for a position
  often lives on its Talk page, any link to a position item now uses
  this template, for easier of access to that. (Requested by Tagishsimon:
  https://twitter.com/Tagishsimon/status/1304363879322079233)

* The change to how warnings templates work from the last release (i.e.
  using on-wiki templates, so they can be improved or translated, or used
  to look for problems via backlinks) definitely seems to have been a good
  idea, so now the warnings for having an unexpected number of inception
  or abolition dates have also been adjusted to work the same way.

# [1.10.0] 2020-09-13

## Enhancements

* If some other position has a "replaces" (P1365) or "replaced by"
  (P1366) pointing to _this_ position, but this position doesn't have
  the reciprocal inverse claims back to that one, include them as a
  successor/predecessor, but warn that it’s only an indirect connection.

* The warnings in the above case now use an on-wiki template for their
  text. This means they can be translated into other languages, and also
  means that backlinks to these templates, via WhatLinksHere, can act as
  a TODO list. The other warnings will be migrated to this approach Real
  Soon Now™.

# [1.9.0] 2020-09-11

## Enhancements

* If a position has any successor or predecessor offices (in "replaces"
  (P1365) or "replaced by" (P1366)) the report will now display those.

# [1.8.0] 2020-09-09

## Enhancements

* If the very latest person we know of having held this position also
  has a 'replaced by' qualifier, that’s a sign that the successor should
  really also have a suitable P39, and actually appear here too. So we
  want to display a warning in such cases. Likewise if the earliest person
  we know if also has a 'replaces'

* This report is meant to be used with positions that are held by only a
  single person at a time. Using it to produce a report of everyone who
  has been, say, a Member of the UK Parliament, is the sort of thing that
  will cause all manner of havoc, as it will try to display tens of
  thousands of people, all of whom have overlaps with other members etc.
  So we now sanity-check first of all that the position isn't legislative,
  and produce a nice "Don’t do that!" message in such cases.

* It seems that the recent ability to handle dates that are only know at
  decade-level precision isn’t actually enough, as we have some that we
  only know at century-level precision! (For example, that the position of
  Lord Chancellor of Ireland was created some time in the 12th Century.)
  Such dates will now appear in a nicer format.

* Sometimes updating the table looks like something has changed, but
  really the only difference is that a few of people who have no dates
  are shuffled around a bit in the list. This is because we previously
  only sorted by date order, so people with no dates were effectively in a
  random order. Now we sort those people by ID too, which should minimise
  the number of times an update will appear in your watchlist, only to
  discover nothing significant actually happened.

# [1.7.0] 2020-09-08

## Enchancements

* Yesterday’s future, when we said we’d do something a little better
  with positions that have multiple inception or abolition dates, has
  arrived. Now we display all of them (with a warning), rather than just
  picking one semi-randomly.

## Improvements

* A query like https://w.wiki/bVz is taking about 6 seconds to run.
  Changing that to https://w.wiki/bW3 drops that to about half a second.
  If you were to guess that the first has now been replaced by the
  second, you’d be entirely correct.

# [1.6.0] 2020-09-07

## Enhancements

* If a position has an inception date and/or abolition date, those will
  now also be displayed. (If a position has more than one of either of
  those — which really shouldn’t happen, but sometimes does — then the
  behaviour may not be particularly sensible. Later evolutions of this
  feature will hopefully handle that better.)

## Fixes

* Previously, any warnings would be displayed at the bottom of the page,
  which was fine if this table was the only thing on the page, but would
  be slightly odd if there was other discussion after it. Now the
  footnotes are explicitly displayed immediately after the table.

# [1.5.0] 2020-09-06

## Enhancements

* When showing the results for a position from long long ago (such as
  the High Kings of Ireland), display the dates as "862 – 879" not as
  "0862 – 0879"
* If we only know that someone took (or left) office sometime in a given
  decade (i.e. at date precision 8), display that as (say) "1930s"

## Fixes

* No longer blows up when a P39 has a start date, but no end date

# [1.4.2] 2020-09-05

## Fixes

* Bring back the warnings when start or end dates are missing.

# [1.4.1] 2020-09-04

## Fixes

* Work around template deployment issue.

# [1.4.0] 2020-09-04

## Enhancements

* Add an image column.
* Improve the warning for inconsistent successor/predecessor values.

# [1.3.4] - 2020-09-01

## Fixes

* Update to latest version of mediawiki-replaceable-content to include
  upstream bug fix.

# [1.3.3] - 2020-08-29

## Enhancements

* Include link to Wikidata Query Service showing the SPARQL used to
  generate the list.

# [1.3.2] - 2020-08-29

## Fixes

* Skip all date checks for items with no dates

# [1.3.1] - 2020-08-28

## Fixes

* Skip the dates line if neither date is set

# [1.3.0] - 2020-08-17

## Enhancements

* Display dates at more accurate levels of precision

# [1.2.0] - 2020-08-14

## Enhancements

* Display inception and/or abolition dates for the position itself.

## Fixes

* If an officeholder held multiple consecutive terms, do not warn that
  they do not have 'replaces' or 'replaced by' statements pointing at
  themselves

# [1.1.0] - 2020-08-14

## Enhancements

* 'Acting' officeholders are visually differtiated in the output, and do
  not require replaces/replaced-by statements
* If no officeholders are found, explicitly say so, rather than
  displaying a completely empty table
* Position ID will be derived from Page name if not supplied

## Fixes

* Deprecated P39 (position held) statements are no longer included

# [1.0.0] - 2017-11-03

Original release by mySociety
