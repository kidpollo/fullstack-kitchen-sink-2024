/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */
if (__DEV__) {
    import("./ReactotronConfig").then(() => console.log("Reactotron Configured"));
}

import {
    StyledSafeAreaView,
    StyledScrollView,
    StyledKeyboardAvoidingView,
    StyledGestureHandlerRootView,
    ProgressBar,
    SwipeableContainer,
} from './components';

import {
    HStack,
    Text,
    Pressable,
    Icon,
    AddIcon,
    Box,
    Link,
    Spinner,
} from '@gluestack-ui/themed';
import 'react-native-get-random-values';
import { v4 as uuidv4 } from 'uuid';
import { useState, useRef } from 'react';
import { getCompletedTasks, getDay } from './utils';

type Todo = {
    id: string;
    task: string;
    created_at: string;
    updated_at?: string;
    completed: boolean;
    modified?: boolean; // Optional property to track modifications
    newTodo?: boolean; // Optional property to track new items
    deleted?: boolean; // Optional property to track deleted items
};

const App = () => {
    const { todos, setTodos, isSyncing } = todo_app.todo_context.useTodos();
    const [item, setItem] = useState('');
    const [swipedItemId, setSwipedItemId] = useState(null);
    const [lastItemSelected, setLastItemSelected] = useState(false);
    const inputRef = useRef(null);

    const updateTodos = (newState: Todo[] | ((todos: Todo[]) => Todo[])) => {
        setTodos((currentTodos: Todo[]) => {
            // Determine if newState is a function or a new state value
            const updatedState = typeof newState === 'function' ? newState(currentTodos) : newState;

            // Find deleted items
            const deletedItems = currentTodos.filter(
                currentTodo => !updatedState.some(updatedTodo => updatedTodo.id === currentTodo.id)
            );

            // Mark deleted items with deleted flag
            if (deletedItems.length > 0) {
                deletedItems.forEach(deletedItem => {
                    deletedItem.deleted = true;
                });
            }

            // Find new items
            const newItems = updatedState.filter(
                updatedTodo => !currentTodos.some(currentTodo => currentTodo.id === updatedTodo.id)
            );

            // Mark new items with newTodo flag
            if (newItems.length > 0) {
                newItems.forEach(newItem => {
                    newItem.newTodo = true;
                });
            }

            // Iterate over the todos to check for changes and mark as modified
            const updatedTodos = updatedState.map(todo => {
                const currentTodo = currentTodos.find(ct => ct.id === todo.id);
                // Check if the todo item exists and has changes
                if (currentTodo && JSON.stringify(currentTodo) !== JSON.stringify(todo)) {
                    return { ...todo, modified: true };
                }
                return todo;
            });

            // concat deleted items with updated/new items
            return updatedTodos.concat(deletedItems);
        });
    };

    const addTodo = () => {
        const lastTodo = todos[todos.length - 1];

        if (lastTodo.task !== '') {
            updateTodos([
                ...todos,
                {
                    id: uuidv4(),
                    task: '',
                    completed: false,
                    created_at: new Date().toISOString(),
                    newTodo: true,
                },
            ]);
            setItem('');
            setLastItemSelected(false);
        }
    };

    return (
        <StyledKeyboardAvoidingView
            w="$full"
            h="$full"
            bg="$backgroundDark900"
            behavior="padding"
            keyboardVerticalOffset={60}>
            <StyledSafeAreaView
                $base-bg="$backgroundDark900"
                $md-bg="$black"
                w="$full"
                h="$full">
                <StyledGestureHandlerRootView
                    w="$full"
                    minHeight="$full"
                    $md-justifyContent="center"
                    $md-alignItems="center"
                    $md-bg="$black">
                    <StyledScrollView
                        pt="$6"
                        pb="$10"
                        bg="$backgroundDark900"
                        $base-w="$full"
                        $md-w={700}
                        $md-maxHeight={500}
                        $md-borderRadius="$sm"
                        flexDirection="column">
                        <Box px="$6">
                            <Box flexDirection="row" justifyContent="space-between">
                                <Text fontSize="$xl" >
                                    {getDay()}
                                </Text>
                                {isSyncing && <Spinner size="small" />}
                            </Box>
                            <ProgressBar
                                completedTasks={getCompletedTasks(
                                    todos,
                                    item != '' && lastItemSelected
                                )}
                                totalTasks={item !== '' ? todos.length + 1 : todos.length}
                            />
                        </Box>

                        {todos.map((todo: any, index: number) => (
                            <SwipeableContainer
                                key={index}
                                todo={todo}
                                todos={todos}
                                setTodos={updateTodos}
                                swipedItemId={swipedItemId}
                                setSwipedItemId={setSwipedItemId}
                            />
                        ))}

                        <Pressable
                            mb="$32"
                            px="$6"
                            $md-mb={0}
                            onPress={() => {
                                addTodo();
                                setTimeout(() => {
                                    if (inputRef?.current) {
                                        inputRef?.current.focus();
                                    }
                                }, 100);
                            }}>
                            <HStack alignItems="center" mt="$4">
                                <Icon as={AddIcon} color="$secondary600" />
                                <Text ml="$2" fontSize="$sm">
                                    Add Task
                                </Text>
                            </HStack>
                        </Pressable>
                        <Link sx={{
                            ":hover": {
                                _text: {
                                    color: 'red'
                                }
                            }
                        }}>
                        </Link>
                    </StyledScrollView>
                </StyledGestureHandlerRootView>
            </StyledSafeAreaView>
        </StyledKeyboardAvoidingView>
    );
};

export default App;
