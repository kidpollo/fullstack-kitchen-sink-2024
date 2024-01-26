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
    Box,
    Input,
    Button,
    ButtonText,
    InputField,
} from '@gluestack-ui/themed';

import { TodosScreen, StyledSafeAreaView } from './components';

import 'react-native-get-random-values';
import { useState, useRef, useEffect } from 'react';

const App = () => {
    const { user, login, logout } = todo_app.user_context.useUser();
    const { todos, setTodos, isSyncing } = todo_app.todo_context.useTodos();
    const [username, setUsername] = useState('');

    const handleLogin = () => {
        login(username);
    };

    useEffect(() => {
        if (user) {
            setTodos([]);
        }
    }, [user]);

    // When logged in, show the todos screen
    if (user) {
        return(
            <TodosScreen
                isSyncing={isSyncing}
                todos={todos}
                setTodos={setTodos}
                user={user}
                logout={logout}
            />
        );
    }

    return (
        <StyledSafeAreaView
            $base-bg="$backgroundDark900"
            $md-bg="$black"
            justifyContent="center"
            w="$full"
            h="$full">
            <Box p="$4" >
                <Input m="$2">
                    <InputField
                        color="$white"
                        value={username}
                        onChangeText={(val: any) => { setUsername(val) }}
                        placeholder="Username"
                        type="text" />
                </Input>
                <Button m="$2" title="Login" onPress={handleLogin}>
                    <ButtonText color="$white">Login</ButtonText>
                </Button>
            </Box>
        </StyledSafeAreaView>
    );
};

export default App;
