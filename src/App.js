import logo from './logo.svg';
import './App.css';
import { authenticate } from './Components/authenticate';
import { login } from './Components/login-user';
import { Button } from '@mui/material';
import { createProfile } from './Components/create-profile';


function App() {
  const request = {
    
      handle: "testthw",
      profilePictureUri: null,   
      followModule: {
            emptyFollowModule: true
        } 
  }
  
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <Button onClick={login}>Login</Button>
        <Button onClick={createProfile}>Create Profile</Button>
      </header>
     
    </div>
  );
}

export default App;
