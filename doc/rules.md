# Rules

Here are the rules of the game.

## Turn

A turn is composed of 2 phases: orders and conflict resolution.

- During the **orders** phase, each player can give one order for each 
  hex they control.
- During the **conflict resolution** phase, all the conflicts that result from 
  the orders given on the previous phase are resolved.

Once all the conflicts have been resolved, the turn ends and a new turn begins, 
until only one player remains.

## Orders

Two orders are available: **move** and **attack**.

### Move

A player can _move_ units from a hex they control to an adjacent one, as long 
as this hex is empty. Any number of units can be moved, but a player must 
leave at least 1 unit on the origin hex.

### Attack

A player can also _attack_ an occupied hex from an adjacent one that they control.
To carry an attack, the player selects any number of units from the origin hex 
(up to 6). Should the conflict resolve in a successful attack, the selected units 
will move to occupy the targeted hex. (However, 1 unit must always stay on the 
origin hex; if the attack was carried with **all** the units from a hex, then 
the targeted hex cannot be occupied and will stay empty.)

## Conflict resolution

The attacking player secretly choses a number between 1 and the number of units they 
carry their attack with. The defender must tries to guess the number picked; if 
they guessed right, the attacker loses that many units, and the rest falls back 
to their origin hex. If they guessed wrong, the defender loses all their units 
on the hex, which can then be occupied by the attacker.
