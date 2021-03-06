{-
  Author    : Tim Dysinger
  Copyright : 2014
  License   : MIT
-}

module Network.AWS where

import Control.Monad.Eff
import Data.String
import Data.Foreign

import Network.AWS.Types

foreign import awsCallback
  """
  function awsCallback(f) {
    return function(e, d) {
      return f(e)(d)();
    }
  }
  """
  :: forall a b e r. AwsFn a b e r -> AwsCallback e

foreign import send
  """
  function send() {
    return function(request) {
      return function(sFn) {
        return function(eFn) {
          return function(cFn) {
            return function() {
              return request.on('success', sFn)
                            .on('error', eFn)
                            .on('complete', cFn)
                            .send();
            }
          }
        }
      }
    }
  }
  """
  :: forall a e r.
     Request
  -> ({|a} -> WithAWS e r)    -- success  callback
  -> ({|a} -> WithAWS e Unit) -- error    callback
  -> WithAWS e Unit           -- complete callback
  -> WithAWS e Unit

foreign import eachItem
  """
  function eachItem(request) {
    return function(callback) {
      return function() {
        request.eachItem(callback);
      }
    }
  }
  """
  :: forall r e1 e2. Request -> AwsCallback e1 -> WithAWS e2 r
