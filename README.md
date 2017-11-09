# demo-profile
Demo of a social network type profile of users and Marvel characters that they follow.

Every time you open the app it's populated with random user data, which includes:
- background and profile photos
- name, location, birthday, relationship user (or single)
- whether it's your own profile or someone else's
- if someone else's, whether you've sent a request, are awaiting a response, have not interacted before or are friends already<br>
and a random starting page of Marvel characters with pagination for more.

**Available interactions:**
- if on your own profile, you can unfollow characters and they will be removed
- if on someone else's, you can follow and unfollow from their list of followed characters
- tapping on Marvel characters takes you to their character page online
- tapping on the background cover photo takes you to the photographer's Unsplash profile

**Known issues:**
- pagination is stuttering from (I believe) an IGListKit issue
    - collection view inside of collection view (needed for pinterest layout) is causing cells not to be reused, causing all to be laid out at once
- code could use some cleanup


Background images provided by [Unsplash](http://www.unsplash.com/?utm_source=parnella_profile&utm_medium=referral&utm_campaign=api-credit).<br>
Data provided by Marvel. © 2014 [Marvel](http://marvel.com).<br>
Profile images provided by [UI Faces](http://uifaces.com/).


