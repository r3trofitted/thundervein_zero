# Notes

## Rules

*   /!\ **I read the Warlord's rules wrong!** A successful attack should only _remove one unit_ from the defender's tile, 
    not wipe them all entirely! Let's continue with the current system (it's not the main goal of this project after all), 
    but we may need to revisit it later.
*   When should a turn end? Once everyone has sent orders? Should the system impose a 
    time limit to avoid abuses or stalling games?

## Gameplay

*   Since TV-0 is a PBeM, let's make it possible to do _everything_ by email: have a list of all the available games, 
    join a game, etc. Like a chatbot with a very cumbersome entry device.
*   Because everything will be done by e-mail, there should be no need for a password nor login system: all info is sent 
    to your email anyway. (Obviously, you're fucked if your email is compromised, but it's always the case anyway.)
*   Let's also have a realtime UI to supervise the ongoing games. (OK, realtime is overkill and certainly irrelevant in 
    a turn-based, PBeM game, but it would be fun to build.)
*   Special case: A attacks B but won't occupy, and C wants to move to B. _Technically_ these are colliding orders
    (both have the same target), but in practice, it _could_ be expected to work. I don't think it should, though, 
    because making it work is order-dependant (i.e. if the move was done _before_ the attack, what? It becomes an attack?)
*   We could introduce a `UpdatesList` object to represent the list of updates (instead of a simple array in `Turn#resolve!`); 
    this object would be in charge of merging its own content (therefore taking a piece of the logic in `Turn#resolve!`), and/or 
    validate its own state, to ensure that no conflicting updates could be passed to `Board#revise`. Overkill?
*   [x] There is a special case of attacks: the "switcheroo attacks", when a player from tile A attack a player from tile B, and
    at the same time, B attacks A. In this situation, nothing special happens if one attack succeeds but not the other, 
    or if both fail. However, if both attacks succeed, then we need to ensure that the game handle the post-victory 
    moves correctly – i.e. that A and B trade places (minus 1 unit, supposedly left behind).
*   [x] In the same vein, how to properly handle "chain orders"? E.g. if A attacks B while B attacks C?
*   [ ] Implement a way to know when a player is eliminated from a game (e.g. strike their name on the monitoring page)
*   Attacks will need a special "pending" status while the game waits for the defender to pick
    a guess. Which means, in turn (ah ah) that a turn resolution will not be atomic.
*   How do we handle _starting_ a game? Once the max number of players is reached? (I don't like this a lot because 
    then it's not a _max_ number.) Should games also have a _min_ number of players? Should the start be automatic or manual?

## Emails

*   Since players will be sending emails to different people, including the game itself 
    (to give orders), there should be a easy way to chose the right recipient, and more 
    importantly, some kind of safeguard to avoid sending something sensible to the wrong 
    person (e.g. sending actual game orders to a player).
*   It could be nice if orders could be sent to a more generic `arbiter@…` address, instead of `orders@…`. But then, 
    the arbiter mailbox would have to do some analysis to understand that the email is about orders, and not 
    anything else game-related. (In other word: the _arbiter_ would be the referee chatbot, not _meant_ to 
    receive orders, but able to do so if necessary.)
*   AR encrypted attributes could/should be used for the players' actual email address.

## Miscellaneous

*   **Jargon**: _Tile_ is the object that represents a section of the board; in game, theses sections are called _zones_.
*   Counter cache on game.turns?