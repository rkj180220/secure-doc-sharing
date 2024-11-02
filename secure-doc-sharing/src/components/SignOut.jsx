import React from 'react';
import { Auth } from 'aws-amplify';

const SignOut = () => {
  const handleSignOut = async () => {
    try {
      await Auth.signOut();
      // Redirect or update your app state after successful sign-out
    } catch (err) {
      console.error('Error signing out:', err);
    }
  };

  return (
    <div>
      <button onClick={handleSignOut}>Sign Out</button>
    </div>
  );
};

export default SignOut;
