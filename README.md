# snowDaze

Author:
Zane
Miller<p>
Date:
Dec
2022<p>
Contact:

    - Email: zanemmiller2@gmail.com
    - Twitter: 
    - Website: 
    - LinkedIn:
    - GitHub: 

<p>
snowDaze is a full stack app that provides users with the tools and resources needed 
to make the best informed decision about which mountain to ride on a given day. The  
application supports resorts in California and Washington and will expand to other 
regions in future updates. 
</p>

## Motivations

<p>
This app started as an app to consolidate resources skiers and snowboarders use to 
forecast conditions on the mountain for any day. Often times, forecasts can vary from 
source to source or provide forecasts for the grid locations that do not always 
reflect the actual conditions on the mountains. Other resources include Twitter feeds 
for local weather forecasters, resorts, and state transportation agencies, state DOT 
updates, and trail maps [OTHERS].
</p>
<p>
Flutter was chosen as the SDK for this project based on its ability to easily build an 
application for multiple devices from one application. The initial intent is to release 
this app on iOS and Android with the goal of then implementing a browser enabled version. 
</p>

## Design

<p>
The application implements a Firestore instance to handle backend data storage and query. 
The application also depends on APIs from various sources including: Open Weather, 
the National Weather Service API, and hopefully access to snow-forecast.com XML access.
</p>

## Process

<p>
Design started with implementing the weather application functionality geared towards 
winter mountain sports. There is backend logic that intends to improve upon the available 
weather forecast API data and implement alert features that inform the user of powder days 
and resorts with the best conditions.
</p>
<p> 
Once the weather app functionality is implemented and stable I intend to focus on 
implementing the functionality that collates the different resources for each resort that 
allows the user to see all pertinent resources in a single page view to allow them to make 
better informed decisions on conditions and safety for the selected resort. 
</p>

## Resources

### Forecast Resources

    - snow-forecast.com
    - mountain-forecast.com
    - nws.gov API <link>
    - Open Weather API <link>

### Twitter Resources

### Traffic Resources