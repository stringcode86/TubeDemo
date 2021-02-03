#  Tube Demo

### Brief overview 

I went with simple MVC architecture. Storyboards are very polarizing amongst iOS devs. Just 
about everyone agrees tough, if there is one place where they shine is when it comes to 
making simple demos / prototypes. That is my justification for using them here.

All the services are implemented as protocols so that mocks can be easily injected. Right
now default implementations are set as default property  values. Service directory could be 
used for easier management or even something more  elaborate like Swinject. All services use 
`NetworkManager` (simple wrapper around `URLSession`) to send requests. (Network manager is 
only code I reused, its older code). 

### There are three main controllers:    

`HomeViewController` extremely rudimentary simple container controller. Ideally I would have 
loved to implement custom containment controller [Example of custom containment controller I 
did in the past](https://github.com/stringcode86/DrawerController). This controller simply
embeds `MapViewController` and `StopsViewController` via embedding segues and hock
up delegate.

`MapViewController` is a location provider via `MapViewControllerDelegate`. It requests 
locations permissions via `UserLocationService`. Defaults to 
`Constant.defaultLocation` (central London) if permissions are not granted or user 
location is outside of M25 (`Constant.londonRegion`).

`StopsTableViewController` implements `MapViewControllerDelegate` to get location.
Uses `StopService` and `ArrivalsService` to load data. Mock services could easily be 
injected. Entire section is used for displaying data for one tube stop. First cell acts as header. 
This is due to facilities requirement. Facilities have non-uniform size. Therefore autosizing cells
seem a natural fit. Autosizing does not work with section headers. When loading stops animations
are not as graceful as I would like. This could be improved by more elaborate diffing. For now 
I'm simply reloading, inserting or deleting sections. Currently there is no loading state. Error 
handling very rudimentary. 

### Other notable

`CollageView` lays out `subviews` in collage. Calls `sizeThatFits(_)` for each view and
proceeds to layout in a rows. Performance could be improved by caching subviews frames 
and invalidated on `invalidateIntrinsicContentSize()` and or `setNeedsLayout()`. 
Due to time constraints and the fact that only handful of views are layout this was skipped. 
Next step would be not to layout subviews directly. API similar to `StackView` ie
 `addArrangedSubview(_)` would be more fitting to make it production ready.

### Next steps

- Unit / UI tests. I have originally intended to include them. Regrettably I ran out of time.
- Above mentioned comments with regards to `CollageView`
- Loading state in `StopViewController`
- More robust error handling in `StopViewController` 
- More robust container controller with ability to swipe `StopViewController` up and 
  down. `UIKitDynamics` to snap it to place.
