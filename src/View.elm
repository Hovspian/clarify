module View exposing (view)

import Html exposing (
    div, text, Html, a, br, hr, button, input, form,
    select, option, map
    )
import Html.Attributes exposing (href, style, align, id, type_, value)
import Html.Events exposing (onClick, onSubmit, onInput)

import Msg exposing (..)
import Model exposing (..)


-- styles
fullSizeStyle = style [("width", "100%"), ("height", "75%")]
width100p = style [("width", "100%")]
htmlAppHeader = div [style [
        ("color", "#1D417D"),
        ("font-size", "28px"),
        ("padding-left", "40%")
    ]] [text "Clarify"]

redFont = style [("color", "red")]
noStyle = style []

currentView model =
    case model.state of
        -- each of these takes a model
        TodayState -> todayView model
        TaskState -> taskView model
        LifeGoalsState -> lifeGoalsView model
        LifeGoalState -> lifeGoalsView model
        DeleteLifeGoal id -> lifeGoalsView model
        _ -> todayView model


lifeGoalSelector life_goals =
    -- TODO need to map each life goal to its ID and give it a Msg message so we can update the task
    select [] (
        List.map
        (\lifeGoal -> (option [] [text lifeGoal.title]))
        life_goals
    )

estimatedMinutesSelector task =
    map
        (\estMin -> UpdateTaskEstimatedMinutes (task.taskID, estMin))
        (input [type_ "number"] [])

tasksToHtmlList model =
    List.map (\task -> [
        text ((toString task.taskID) ++ " " ++ task.title ++ " "),
        -- ability to select a life goal for this task
        -- TODO this will need to pass in the id of the current task so we can map it to the life goal the user selects
        (lifeGoalSelector model.life_goals),
        -- estimated minutes
        estimatedMinutesSelector task,
        br [] []
    ]) model.tasks

-- tasks view shows all tasks
taskView model =
    div [fullSizeStyle]
        (List.append
            (List.concat (tasksToHtmlList model))
                [
                    br [] [],
                    br [] [],
                    text "Create a Task",
                    br [] [],
                    --text "TaskState",
                    text "Life Goal: ",
                    lifeGoalSelector model.life_goals,
                    br [] [], 
                    br [] [],                 
                    form [onSubmit CreateTask] [
                        text "Description: ",
                        input [
                            onInput UpdateTaskRegister
                        ] [],
                        br [] [],
                        br [] [],
                        text "Time: ",
                        input [type_ "number"][],
                        text " Minutes", 
                        br [] [],
                        br [] [],
                        button [type_ "submit"] [text "Create"] 
                    ]  
         ]
    )

-- today view shows tasks we chose for today
todayView: Model -> Html Msg
todayView model = div [fullSizeStyle]
    (List.map (\x -> text x.title) model.today.tasks)

lifeGoalElement: LifeGoal -> Html Msg
lifeGoalElement lifeGoal =
    div [width100p] [
        text lifeGoal.title,
        text " ",
        button [(onClick (DeleteLifeGoal lifeGoal.id))] [text "Delete"]
    ]

lifeGoalsView: Model -> Html Msg
lifeGoalsView model = div [fullSizeStyle]
    (List.append
         (List.map lifeGoalElement model.life_goals)
         [
            br [] [],
            br [] [],
            text "Create a Life Goal",
            br [] [],
            form [onSubmit CreateLifeGoal] [
                text "Description: ",
                input [
                  onInput UpdateCreateLifeGoalRegister
              ] [],
              br [] [],
              button [type_ "submit"] [text "Create"]
           ]]
     )


--navigation: () -> Html msg
-- navigation should be able to switch us between the states.
htmlNavigationBar model = div [] [
        -- these links need to be attached to onClick events,
        -- or something of the like
        a [
            -- these links don't take us anywhere yet,
            -- but at least we can click them.
            (href "#"),
            (onClick TodayState),
            (if model.state == TodayState then redFont else noStyle)
        ] [text "Today"],
        -- put some spacing between the links
        text " ",
        todayLinkButton model,
        text " ",
        lifeGoalsLinkButton model
    ]

lifeGoalsLinkButton model =
    a [
        (href "#"),
        (onClick LifeGoalsState),
        (if model.state == LifeGoalsState then redFont else noStyle)
    ] [text "Life Goals"]

todayLinkButton model =
    a [
        (href "#"),
        (onClick TaskState),
        (if model.state == TaskState then redFont else noStyle)
    ] [text "Tasks"]

createViewButton model =
    a [
        (href "#"),
        (onClick CreateState),
        (if model.state == CreateState then redFont else noStyle)
    ] [text "Create"]


mainViewHtmlNavigationBar = div [] [
        -- these links need to be attached to onClick events,
        -- or something of the like
        a [
            -- these links don't take us anywhere yet,
            -- but at least we can click them.
            (href "#"),
            (onClick TodayState)
        ] [text "Today"],
        -- put some spacing between the links
        text " ",
        a [
            (href "#")
--            ,
--            (onClick LifeGoalsState)
        ] [text "Life Goals"]
    ]

-- we need to create a state that holds the current state -
-- are we looking at life goals, priorities, tasks, or
-- today? (i.e. create a corresponding version of "type Msg
-- = Increment | Decrement") depending on the state we're
-- in, we need to show the model in a way that is useful,
-- with interactivity.
view: Model -> Html Msg
view model =
    div [fullSizeStyle] [
        text (toString model.debug),
        htmlAppHeader,
        htmlNavigationBar model,
        hr [] [],
        text (toString model),
        hr [] [],
        currentView model
    ]

