from fastapi import HTTPException, Header
import jwt


# Middleware to authenticate the user using JWT token
# This middleware will be used in all the routes that require authentication
# It will check if the token is valid and if the user is authorized to access the route
# If the token is valid, it will return the user id and token
# If the token is not valid, it will raise an HTTPException with status code 401
def auth_middleware(x_auth_token = Header()):
    try:
        # get the user token from the headers
        if not x_auth_token:
            raise HTTPException(401, 'No auth token, access denied!')
        # decode the token
        verified_token = jwt.decode(x_auth_token, 'password_key', algorithms=['HS256'])

        if not verified_token:
            raise HTTPException(401, 'Token verification failed, authorization denied!')
        # get the id from the token
        uid = verified_token.get('id')
        return {'uid': uid, 'token': x_auth_token}
    except jwt.PyJWTError:
        raise HTTPException(401, 'Token is not valid, authorization failed!')