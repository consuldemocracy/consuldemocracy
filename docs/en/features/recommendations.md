# Debates and proposals recommendations

Logged in users can see recommended debates or proposals by sorting them by "recommendations".

The sorted list shows, ordered by votes in descending order, those elements that:

1. Have tags that interest the user. Those tags are the ones on the proposals that the user follows.
2. The user isn't the author.
3. In the case of proposals: only those that haven't reached the required threshold of votes and the user isn't already following.

## How to try this feature

In our local installation, if we haven't logged in, we can check at <http://localhost:3000/proposals> that the "recommendations" sorting option isn't present:

![The sorting options don't include "recommendations"](../../img/recommendations/recommendations_not_logged_in.jpg)

Once we log in we see the menu, but since we aren't following any proposals we get the message "Follow proposals so we can give you recommendations" at <http://localhost:3000/proposals?locale=en&order=recommendations&page=1>

![Recommendations are empty](../../img/recommendations/recommendations_no_follows.jpg)

Follow any proposal using the "Follow citizen proposal" button on the side menu:

![Button to follow a citizen proposal](../../img/recommendations/recommendations_follow_button.jpg)

Now we can finally see some recommendations:

![List of recommendations](../../img/recommendations/recommendations_with_follows.jpg)

The feature works the same way for debates.
