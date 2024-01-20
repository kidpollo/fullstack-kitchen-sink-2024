/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

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
} from '@gluestack-ui/themed';
import 'react-native-get-random-values';
import { v4 as uuidv4 } from 'uuid';
import { useState, useRef, useContext } from 'react';
import { getCompletedTasks, getDay, defaultTodos } from './utils';

const App = () => {
    const { todos: t } = todo_app.todo_context.useTodos();
    const [item, setItem] = useState('');
    const [todos, setTodos] = useState(defaultTodos);
    const [swipedItemId, setSwipedItemId] = useState(null);
    const [lastItemSelected, setLastItemSelected] = useState(false);
    const inputRef = useRef(null);

    const addTodo = () => {
        const lastTodo = todos[todos.length - 1];

        if (lastTodo.task !== '') {
            setTodos([
                ...todos,
                {
                    id: uuidv4(),
                    task: '',
                    completed: false,
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
                            <Text fontSize="$xl">
                                {getDay()}
                            </Text>
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
                                setTodos={setTodos}
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
