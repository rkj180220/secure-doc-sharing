import React, { useEffect, useState } from 'react';
import { Auth } from 'aws-amplify';
import SignIn from './SignIn';
import SignOut from './SignOut';

const AuthStatus = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkUser = async () => {
      try {
        await Auth.currentAuthenticatedUser();
        setIsAuthenticated(true);
      } catch (err) {
        setIsAuthenticated(false);
      }
      setLoading(false);
    };

    checkUser();
  }, []);

  if (loading) {
    return <p>Loading...</p>;
  }

  return (
    <div>
      {isAuthenticated ? (
        <div>
          <h2>Welcome Back!</h2>
          <SignOut />
        </div>
      ) : (
        <SignIn />
      )}
    </div>
  );
};

export default AuthStatus;
