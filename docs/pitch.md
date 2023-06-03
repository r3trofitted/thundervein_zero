# Pitch

Thundervein Zero will be a simple [play-by-mail game](https://en.wikipedia.org/wiki/Play-by-mail_game), with a gameplay 
inspired by [The Warlord](https://en.wikipedia.org/wiki/The_Warlord_(board_game), which is itself close to a Risk rip-off.

The main distinguishing features of this game will be:

- The possibility of giving order using natural language, so that instead of using a GUI you'll be able to send an email 
  stating something like “I want to move 4 units from A to attack B” or “Dear arbiter, please acknowledge my intend to 
  attack B with 4 units from A".
- Chatbots used to power the computer players, negotiating alliances and, possibly, betraying them, so that the feeling 
  of having epistolary interactions with other players can be maintained.

## Motivations

Action Mailbox is one of the only Rails components that I've never used, and I'm looking for an excuse to remedy that. 
Besides, having a NLP-based UI will be a interesting challenge, since I've only brushed the surface of this whole field. 
Finally, I'd love to see if ChatGPT or similar services can actually by used to simulate human players negotiating around 
a game table (and if I can pull it off…)

I've chosen The Warlord as a basis for the game, even though I've never played it, because it's mentioned (and highly 
praised!) in [Dice Men: The Origin Story of Games Workshop](https://unbound.com/books/games-workshop/), which I'm 
currently enjoying.

The name has been generated on a random website; it sounds like the name of a shoot'em up, which I find interesting. 
Maybe the game could be about mechas and terraforming distant planted?

## Plan:

1.  Build the core game engine, without any UI – turn orders can be created and the game state can be provided.

    A very, very simple gameplay is enough for a start – something like a board with only 4 locations, no 
    army production or upkeep, no terrain modifications, etc. Just a conflict resolution system, basically, 
    plus a very minimal UI to spectate (or debug) the game.
2.  Add an e-mail based system to enter orders and be updated on the game state.

    This will require a system to identify the game from the email (e.g. each game could have its own address), 
    parse the received orders, apply some validation, and provide some kind of confirmation.   
3.  Add an e-mail based system to create or join a game.
4.  Add a “dispatching system” so that players can exchange e-mails without sharing their own address.
5.  Add some NLP magic to make the entering of orders more fun and human-sounding.
6.  Add some AI logic.
7.  Add conversational capabilities to the AI, so that it can also send and receive e-mails from the players.
