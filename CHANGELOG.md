# Changelog

# Unrelased

# Improvements

* A query like https://w.wiki/bVz is taking about 6 seconds to run.
  Changing that to https://w.wiki/bW3 drops that to about half a second.
  If you were to guess that the first has now been replaced by the
  second, you'd be entirely correct.

# [1.6.0] 2020-09-07

## Enhancements

* If a position has an inception date and/or abolition date, those will
  now also be displayed. (If a position has more than one of either of
  those — which really shouldn't happen, but sometimes does — then the
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
  "862 – 879"
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
