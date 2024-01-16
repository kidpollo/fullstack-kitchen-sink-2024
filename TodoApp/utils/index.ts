const getCompletedTasks = (todos: any, lastItemSelected: any) => {
  let complete = 0;
  todos.forEach((item: any) => {
    if (item.completed) {
      complete++;
    }
  });
  if (lastItemSelected) return complete + 1;
  else return complete;
};

const getDay = () => {
  const currentDate = new Date();
  const daysOfWeek = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  const currentDay = daysOfWeek[currentDate.getDay()];
  return currentDay;
};

const defaultTodos = [
  {
    id: 1,
    task: "Schedule the next meeting.",
    completed: false,
  },
  {
    id: 2,
    task: "Share the agenda with the person.",
    completed: false,
  },
  {
    id: 3,
    task: "Review previous meeting notes..",
    completed: false,
  },

  {
    id: 4,
    task: "Prepare any feedback or updates..",
    completed: false,
  },
  {
    id: 5,
    task: "Review progress on goals and projects.",
    completed: false,
  },
  {
    id: 6,
    task: "Ask challenges and discuss.",
    completed: false,
  },
  {
    id: 7,
    task: "Discuss needs or training opportunities.",
    completed: false,
  },
];

export { getCompletedTasks, getDay, defaultTodos };
