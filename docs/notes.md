# Notes

*   /!\ **I read the Warlord's rules wrong!** A successful attack should only _remove one unit_ from the defender's zone, 
    not wipe them all entirely! Let's continue with the current system (it's not the main goal of this project after all), 
    but we may need to revisit it later.
*   When should a turn end? Once everyone has sent orders? Should the system impose a 
    time limit to avoid abuses or stalling games?
*   Since players will be sending emails to different people, including the game itself 
    (to give orders), there should be a easy way to chose the right recipient, and more 
    importantly, some kind of safeguard to avoid sending something sensible to the wrong 
    person (e.g. sending actual game orders to a player).
*   AR encrypted attributes could/should be used for the players' actual email address.
*   Attacks will need a special "pending" status while the game waits for the defender to pick
    a guess. Which means, in turn (ah ah) that a turn resolution will not be atomic.
*   Special case: A attacks B but won't occupy, and C wants to move to B. _Technically_ these are colliding orders
    (both have the same target), but in practice, it _could_ be expected to work. I don't think it should, though, 
    because making it work is order-dependant (i.e. if the move was done _before_ the attack, what? It becomes an attack?)
*   [x] There is a special case of attacks: the "switcheroo attacks", when a player from zone A attack a player from zone B, and
    at the same time, B attacks A. In this situation, nothing special happens if one attack succeeds but not the other, 
    or if both fail. However, if both attacks succeed, then we need to ensure that the game handle the post-victory 
    moves correctly – i.e. that A and B trade places (minus 1 unit, supposedly left behind).
*   [x] In the same vein, how to properly handle "chain orders"? E.g. if A attacks B while B attacks C?
*   [ ] Implement a way to know when a player is eliminated from a game (e.g. strike their name on the monitoring page)