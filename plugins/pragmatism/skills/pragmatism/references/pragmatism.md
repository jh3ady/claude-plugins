# Pragmatism reference

The detailed reference behind the skill: the sources, the tips and chapters
behind each sizing question, the cost model of a presumptive feature, the
tactical versus strategic distinction, Worse is Better as a trade-off rather
than a creed, a worked example sizing the same feature at three lifespans,
and trade-off notes.

Standards and sources:

- David Thomas and Andrew Hunt, *The Pragmatic Programmer*, 20th Anniversary
  Edition (Pragmatic Bookshelf, 2019): the tips cited below use the 2019
  numbering, verified against the official list at
  https://pragprog.com/tips/. Topic 27, "Don't Outrun Your Headlights", is
  freely available at
  https://media.pragprog.com/titles/tpp20/dont-outrun-your-headlights.pdf.
  Hunt and Thomas restate the good-enough argument in their 2003 interview
  [Good Enough Software](https://www.artima.com/articles/good-enough-software).
- John Ousterhout, *A Philosophy of Software Design* (Yaknyam Press, 2018;
  2nd edition 2021): complexity, tactical versus strategic programming, the
  investment mindset, design it twice.
- Titus Winters, Tom Manshreck, and Hyrum Wright, *Software Engineering at
  Google* (O'Reilly, 2020), chapter 1, freely available at
  https://abseil.io/resources/swe-book/html/ch01.html: programming integrated
  over time, expected lifespan, trade-offs and costs, Hyrum's Law.
- Kent Beck, *Tidy First? A Personal Exercise in Empirical Software Design*
  (O'Reilly, 2023), with the underlying theory on Beck's newsletter:
  [Constantine's Equivalence](https://newsletter.kentbeck.com/p/constantines-equivalence)
  and [Coupling and Cohesion](https://newsletter.kentbeck.com/p/coupling-and-cohesion):
  cost of software as cost of change, optionality, reversibility, when to
  tidy.
- Dan McKinley, [Choose Boring Technology](https://mcfunley.com/choose-boring-technology)
  (2015) and the talk version at https://boringtechnology.club/: innovation
  tokens, known and unknown unknowns, operational cost.
- Richard P. Gabriel, [The Rise of Worse is Better](https://www.dreamsongs.com/RiseOfWorseIsBetter.html)
  (1990, circulated from 1991) and its history at
  https://www.dreamsongs.com/WorseIsBetter.html: the MIT and New Jersey
  orderings of simplicity, correctness, consistency, and completeness.
- Martin Fowler's bliki: [Yagni](https://martinfowler.com/bliki/Yagni.html)
  (2015) for the four costs of a presumptive feature,
  [DesignStaminaHypothesis](https://martinfowler.com/bliki/DesignStaminaHypothesis.html)
  (2007) for the design payoff line, and
  [TechnicalDebt](https://martinfowler.com/bliki/TechnicalDebt.html) for the
  interest metaphor.

Where a quotation below is marked "widely quoted", it was verified only
through secondary sources, not against the page of the book.

---

## What pragmatism means here

The word is overloaded. In this marketplace it has one meaning: a principle
is applied where its payoff, over the expected life of the code, exceeds its
cost, and not elsewhere. That definition has three consequences.

- A principle is never right or wrong in itself. Hexagonal architecture is
  right for the ten-year product and wrong for the one-month script; the
  principle did not change, the code did.
- The judgement is symmetric. Over-engineering (paying for structure the code
  will never use) and under-engineering (skipping structure the code will
  pay for many times) are the same mistake in opposite directions: a cost
  estimated wrongly.
- The judgement needs inputs. Without an expected lifespan, a scale, a
  reversibility cost, and an agreed definition of "good enough", "be
  pragmatic" is an empty instruction. The skill's five questions exist to
  gather those inputs.

## Programming integrated over time

*Software Engineering at Google* opens with the definition this skill is built
on: "Software engineering is programming integrated over time." Programming
produces code that works now; engineering keeps it useful across its lifespan.
The chapter names three differences between the two: time, scale, and the
trade-offs at play.

The central question is "What is the expected life span of your code?" A
project is sustainable "if, for the expected life span of your software, you
are capable of reacting to whatever valuable change comes along, for either
technical or business reasons." A one-hour script needs no sustainability
plan; a decades-long system needs one from the start. The book's own examples
range over five orders of magnitude, and the engineering appropriate to each
end is different in kind, not only in degree.

Two further ideas from the chapter feed the sizing questions:

- **Hyrum's Law**: "With a sufficient number of users of an API, it does not
  matter what you promise in the contract: all observable behaviors of your
  system will be depended on by somebody." Scale turns every accidental
  behaviour into a commitment, which is why scale raises the cost of
  reversing a decision.
- **Trade-offs and costs**: cost includes effort, money, resources,
  personnel, transaction, opportunity, and societal costs. Decisions should
  be justified by evidence: "We are doing this because it is the best option
  we can see at the time, based on current evidence." Not "because I said
  so", and not because a book said so either.

The chapter also observes that "The more frequently you change your
infrastructure, the easier it becomes to do so." The slogan "if it hurts, do
it more often" is older, from Extreme Programming, and is usually credited to
Fowler; the Google chapter supplies the evidence, not the slogan.

## Reversibility over prediction

The Pragmatic Programmer devotes a topic to reversibility (Topic 11), with two
tips: Tip 18 "There Are No Final Decisions" and Tip 19 "Forgo Following Fads".
The deeper principle is Tip 14, "Good Design Is Easier to Change Than Bad
Design" (the ETC principle, Topic 8): the only reliable test of a design
decision is whether it made the next change easier.

Topic 27, "Don't Outrun Your Headlights", turns this into a working method.
"We can't see too far ahead into the future, and the further off-axis you
look, the darker it gets." Hence Tip 42, "Take Small Steps, Always": "Always
take small, deliberate steps, checking for feedback and adjusting before
proceeding. Consider that the rate of feedback is your speed limit." And Tip
43, "Avoid Fortune-Telling", which names the four kinds of fortune-telling
to avoid: estimating completion dates months ahead, planning a design for
future maintenance or extendability, guessing users' future needs, and
guessing future technology. The alternative: "Instead of wasting effort
designing for an uncertain future, you can always fall back on designing your
code to be replaceable. Make it easy to throw out your code and replace it
with something better suited."

Kent Beck states the consequence for where to spend attention: "Most software
design decisions are easily reversible, hence there is little value to
avoiding mistakes" (*Tidy First?*, widely quoted). Review effort, the second
design, and the prototype belong on the irreversible decisions. A public API
contract, a persisted schema, a message format consumed by others, the
framework at the core: these are expensive to reverse, and Hyrum's Law makes
them more so with every user. A module boundary inside one codebase, a class
shape, a helper: cheap to reverse, so decide fast and let refactoring correct
the guess.

## The cost of a presumptive feature

Fowler's Yagni entry defines the principle as "a statement that some
capability we presume our software needs in the future should not be built
now", and gives the four costs that the presumption incurs:

- **Cost of build**: the effort spent building it.
- **Cost of delay**: the valuable work displaced while building it.
- **Cost of carry**: the complexity every future change has to read, test,
  and work around, whether or not the feature is ever used.
- **Cost of repair**: the rework when the guess turns out wrong, which it
  often does, because the need was imagined rather than observed.

The carry cost is the one most often forgotten and the one that makes the
"it's only a small interface" argument weak: an interface with one
implementation is read by every future maintainer and defended in every
review, and its actual cost is that reading, not the twenty lines.

Fowler's crucial caveat: "Yagni only applies to capabilities built into the
software to support a presumptive feature, it does not apply to effort to make
the software easier to modify." Tests, refactoring, and continuous delivery
are what make yagni safe; they are not violations of it. This is the line
between pragmatism and sloppiness, stated in one sentence.

### The design payoff line

Fowler's Design Stamina Hypothesis: "Putting effort into the design of your
software improves the stamina of your project, allowing you to go faster for
longer." A project with no design starts faster and slows down as complexity
accumulates; a project with good design starts slower and keeps its speed.
The two curves cross at the **design payoff line**. "If the functionality for
your initial release is below the design payoff line, then it may be worth
trading off design quality for speed; but if it's above the line then the
trade-off is illusory."

Fowler adds that in his experience the line is crossed within weeks, not
months. That is the empirical basis for the skill's claim that shortcuts on
anything but throwaway code are simply debt: "The extra effort that it takes
to add new features is the interest paid on the debt."

### Beck's cost model

Beck reduces the cost of software to a chain he calls Constantine's
Equivalence, after Yourdon and Constantine's *Structured Design*:
"cost(software) ~= cost(change) ~= cost(big changes) ~= coupling". Change
sizes follow a power law, so a handful of big, cascading changes dominate the
total; cascades come from coupling ("Two elements are coupled to the degree
that changes to one tend to require changes in another"); therefore reducing
coupling is what reduces the cost of software. The practical corollary for
sizing: the structure worth paying for is the structure that keeps changes
from cascading, and nothing else.

Beck also names the second value of software, beyond what it does today:
"the possibility of new things we can make it do tomorrow", its
**optionality**. Options are worth more under uncertainty, and they are worth
something even if never exercised. The pragmatic reading is that cheap
optionality (a clean seam, a small module, tidy code) is worth keeping, and
expensive optionality (a plugin system, a provider registry, a second
persistence engine) is worth buying only when the option is about to be
exercised.

## Tactical versus strategic programming

Ousterhout defines complexity as "anything related to the structure of a
software system that makes it hard to understand and modify the system", with
three symptoms (change amplification, cognitive load, unknown unknowns; "Of
the three manifestations of complexity, unknown unknowns are the worst") and
two causes: "Complexity is caused by dependencies and obscurity."

His chapter 3 is titled "Working Code Isn't Enough". **Tactical programming**
aims to get the feature working as fast as possible; each shortcut is small,
and complexity accumulates from hundreds of them. **Strategic programming**
holds that working code is not the primary goal; a good design that also
works is. Its extreme case is the **tactical tornado**: "a prolific
programmer who pumps out code far faster than others but works in a totally
tactical fashion", leaving a wake that others clean up.

The investment figure usually cited from the book is 10 to 20 percent of
development time spent on design, continuously (widely quoted). A project run
that way starts slightly slower and pays back within months, after which the
earlier investments fund the later ones. Two habits carry most of the value:

- **Design it twice**: "Consider multiple options for each major design
  decision. It's unlikely that your first thoughts will produce the best
  design." And: "Designing it twice does not need to take a lot of extra
  time." Two sketches and a comparison, for the decisions that are expensive
  to reverse.
- **Working code isn't enough**: the shortcut that ships today and costs a
  day every month afterwards was never the pragmatic choice; it only looked
  like one because the cost of carry was invisible at the time.

Ousterhout is the least "good enough" of the sources here, and Beck positions
*Tidy First?* partly against his always-design stance. The skill keeps both:
Ousterhout for the steady investment that prevents the tactical tornado, Beck
and Hunt and Thomas for sizing that investment to what the next change needs.

## Good-enough software

Topic 5 of *The Pragmatic Programmer* is titled "Good-Enough Software", and
its tip is Tip 8, "Make Quality a Requirements Issue". Good enough does not
mean sloppy: the software must still meet its users' requirements, and the
users take part in deciding what those are, including how many rough edges
they will accept in exchange for having it sooner. Hunt and Thomas note that
users often prefer software with some rough edges today over waiting a year
for the polished version, and they describe the economics in their 2003
interview: perfection is unaffordable outside a few domains (they cite the
space shuttle's cost per line), and regular user feedback is what tells you
when to stop.

When to stop is the painter's problem: "Don't spoil a perfectly good program
by overembellishment and over-refinement." The later tips restate it from the
delivery side: Tip 87, "Do What Works, Not What's Fashionable"; Tip 88,
"Deliver When Users Need It"; Tip 96, "Delight Users, Don't Just Deliver
Code". Tip 36, "You Can't Write Perfect Software", is the honest premise
behind all of them.

## Boring technology

McKinley's essay gives the sizing question its technology dimension.

- **Innovation tokens**: "Let's say every company gets about three innovation
  tokens. You can spend these however you want, but the supply is fixed for a
  long while." The number is fictional; the scarcity is real, because every
  new technology has to be learned, operated, monitored, and debugged by the
  same small team.
- **Boring is not bad**: "There is technology out there that is both boring
  and bad. You should not use any of that. But there are many choices of
  technology that are boring and good, or at least good enough." What makes
  boring technology valuable is that "you know why it's bad. You can list all
  of the main ways it will let you down."
- **Known and unknown unknowns**: "A known unknown is something like: we
  don't know what happens when this database hits 100% CPU. An unknown
  unknown is something like: geez it didn't even occur to us that writing
  stats would cause GC pauses." New technology has more of both.
- **Operational cost dominates**: "It is basically always the case that the
  long-term costs of keeping a system working reliably vastly exceed any
  inconveniences you encounter while building it." Or, from the talk: "Adding
  the technology is easy, living with it is hard."
- **Optimise globally**: "the 'best' tool is the one that occupies the 'least
  worst' position for as many of your problems as possible."

McKinley does not forbid new technology. He asks that adopting it be a
deliberate, company-wide decision with a plan to retire what it replaces, so
that the token is spent rather than leaked.

## Worse is Better, as a trade-off rather than a creed

Gabriel's essay contrasts two design philosophies by how they order four
qualities. The **MIT approach** ("the right thing") holds that the design
must be simple in both implementation and interface, "correct in all
observable aspects", never inconsistent, and as complete as is practical;
correctness and consistency are non-negotiable, and interface simplicity
outranks implementation simplicity. The **New Jersey approach** ("worse is
better") reorders them: "It is more important for the implementation to be
simple than the interface"; "It is slightly better to be simple than
correct"; "Consistency can be sacrificed for simplicity"; "Completeness can
be sacrificed in favor of any other quality."

Gabriel's observation: "worse-is-better, even in its strawman form, has
better survival characteristics than the-right-thing." The simple, half-right
thing ships, spreads, and is improved to most of what was wanted; the right
thing arrives too late to matter.

Two cautions for using this. First, Gabriel never settled the question: he
attacked his own essay under a pseudonym, defended it a year later, submitted
opposing position papers to the same conference, and wrote "I still can't
decide." Treat it as evidence that shipping a simple, imperfect thing is often
the winning move, not as permission to ship something incorrect. Second, "It
is slightly better to be simple than correct" is about design completeness,
not about defects in what you do ship; nothing here relaxes the correctness
floor for the behaviour a user relies on.

## Not sloppiness: entropy and broken windows

Topic 3 of *The Pragmatic Programmer*, "Software Entropy", gives Tip 5,
"Don't Live with Broken Windows". One tolerated bad design, one wrong
decision left in place, one poor piece of code, and the rest decays faster,
because the signal is that nobody cares. The fix is to repair the window when
you see it, or at least board it up: comment it out, put up a "not
implemented" message, substitute dummy data, so the damage is contained and
visibly owned.

The companion topic, "Stone Soup and Boiled Frogs", gives Tip 6, "Be a
Catalyst for Change" (show a small working thing and let people add to it,
rather than asking permission for the whole) and Tip 7, "Remember the Big
Picture" (decay, like the water heating around the frog, is gradual; keep
checking the whole, not only the change in front of you).

Together with Fowler's caveat that yagni never applies to making software
easier to modify, and Beck's tidyings ("tiny changes to the structure, not
the behavior, of your code"), these draw the floor pragmatism never goes
below: the code that exists is kept in good order, tested to the level its
lifespan demands, and secure at its trust boundaries. Pragmatism decides how
much to build; it does not decide to let what is built rot.

### When to tidy, as a model for when to apply any principle

Beck's answer to "tidy first?" is "it depends", and the four answers make a
good template for sizing any structural investment:

- **Never**: the code will not change again. Leave it.
- **Later**: the tidying would help, but there is no bandwidth now. Keep a
  list.
- **After**: the tidying follows a behaviour change in the same area and
  makes the next one easier. Do it in a separate commit.
- **First**: the tidying makes the imminent behaviour change easier or
  clearer. Do it now, before the change.

Read "tidying" as "applying the principle" and the same four answers size a
port, an aggregate, a read model, or a test suite.

## Worked example: one feature, three lifespans

The feature is the same in all three cases: read a CSV export of orders and
push the rows into a spreadsheet. What changes is the answer to the sizing
questions.

### Lifespan: one month, one user, run by hand

Reversibility: total (delete the file). Scale: one operator, three hundred
rows. Operational cost: none beyond the person running it.

```typescript
// sync-orders.ts: run by hand every Monday; delete when the export is retired.
const csv = readFileSync("exported-orders.csv", "utf8");
const rows = parse(csv, { columns: true });
const values = rows.map((r) => [r.id, r.customer, r.total, r.placedAt]);
await sheets.spreadsheets.values.update({
  spreadsheetId: process.env.SHEET_ID!,
  range: "Orders!A2",
  valueInputOption: "RAW",
  requestBody: { values },
});
```

The pragmatic corrections are about correctness, not structure: a real CSV
parser instead of `split(",")` (quoted fields exist), and writing before
clearing so a failed run does not leave an empty sheet. No port, no domain
layer, no test suite: the test is the operator looking at the sheet. Trigger
to reopen: the job is scheduled (nobody watches it any more), or a second
consumer wants the same data.

### Lifespan: a year, scheduled nightly, one team, two sinks

Reversibility: moderate; the sheet's readers now depend on column order
(Hyrum's Law at small scale). Scale: nightly, unattended. Operational cost:
someone is paged when it fails.

Now the questions buy structure: a function that maps an order row to its
output tuple, tested with three or four representative rows; the two sinks
behind one small interface, because the second sink is real, not presumed;
idempotent writes and a log line per run. Still one module, still no
framework. Trigger to reopen: a third sink, or a consumer who needs the data
in near real time.

### Lifespan: a decade, a product feature, many customers

Reversibility: low; the export format is part of the product's contract.
Scale: every customer, with support tickets when it fails.

Here the full sibling toolkit applies and should be applied properly: a use
case with a port for the export source and one for each destination, an
adapter per destination, contract tests against the destinations, a schema
version on the export, and the design done twice before the contract is
published. The principle did not become more true; the code became something
whose cost of change justifies paying for it.

## Trade-off notes

**Sizing needs evidence, not vibes.** "It might grow" is fortune-telling;
"a second customer signed for the Mollie integration in March" is evidence.
When the evidence is absent, choose the reversible option and set the trigger
that would produce the evidence.

**A thin seam is cheap optionality; a framework is not.** An interface with
one implementation, at a boundary where a second implementation is plausible,
costs a few lines of carry and preserves an option. A registry, a factory, a
selection strategy, and a capability matrix for that same single
implementation cost a great deal of carry for the same option. Pay for the
seam; do not pay for the machinery until the option is being exercised.

**Under-engineering hides as speed.** The tactical tornado looks pragmatic
for a quarter. Watch for change amplification (a simple change touching many
files) and rising cognitive load as the symptoms that the design payoff line
has been crossed and the shortcuts are now interest.

**Good enough is decided with the user, not for them.** A developer who
ships less polish than the user agreed to is not being pragmatic; a developer
who ships more than the user asked for, at the cost of the date, is not
either. Make quality a requirements issue and negotiate it out loud.

**Boring beats clever at the operational layer especially.** The novelty
budget is best spent where it changes what the product can do, almost never
on infrastructure, where the cost of unknown unknowns is paid at three in the
morning.

**When the user overrides the sizing, the sizing was still worth stating.**
Provide options, not excuses (Tip 4): state the mismatch, give the
proportionate design, name the trigger, then build what the owner of the cost
decides. The decision is theirs; the honest sizing is the skill's job.
