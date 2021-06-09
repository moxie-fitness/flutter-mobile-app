# Routes

### Template

| Route | Params | Page |
| ------ | ------ | ------ |
| /users/:id | ---  | Page |


### Home

| Route | Params | Page |
| ------ | ------ | ------ |
| /home/:userImgUrl | userImgUrl : User Image Url from Provider  |``` HomePage : { FeedPage, DashboardPage, CalendarPage }```|


### Users
| Route | Params | Page |
| ------ | ------ | ------ |
| /users/:id | ``` id : User Id  ``` | UserProfilePage |

### Postable
| Route | Params | Page |
| ------ | ------ | ------ |
| /postables/:id/comments| ``` { id : postables Id } ``` | PostsCommentsPage |

### Exercises
| Route | Params | Page |
| ------ | ------ | ------ |
| /exercises/:id |``` id : Exercise Id``` | ExerciseDetailsPage |
| /exercises/create | ```id : Exercise Id ```| ExerciseCreatePage |

### Workouts
| Route | Params | Page |
| ------ | ------ | ------ |
| /workouts/:id | ``` id : Workout Id ```| WorkoutDetailsPage |
| /workouts/create |``` id : Workout Id ```| WorkoutCreatePage |


### Routines
| Route | Params | Page |
| ------ | ------ | ------ |
| /routines/:id | ``` id : Routine Id ```| RoutineDetailsPage |
| /routines/create |``` id : Routine Id ```| RoutineCreatePage |
| /routines/:id/reviews |``` id : Routine Id ```| RoutineReviewsPage |


### Completable
| Route | Params | Page |
| ------ | ------ | ------ |
| /completable/:id/:type | ``` { id : Completed event Id, type: Type of event  } ``` | ``` CompletedWorkoutPage  ```
