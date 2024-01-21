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
    task: "Sample task.",
    completed: false,
    created_at: "2021-08-01T00:00:00.000Z",
  },
];

export { getCompletedTasks, getDay, defaultTodos };
