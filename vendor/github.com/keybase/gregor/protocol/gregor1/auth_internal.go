// Auto-generated by avdl-compiler v1.3.3 (https://github.com/keybase/node-avdl-compiler)
//   Input file: gregor1/auth_internal.avdl

package gregor1

import (
	rpc "github.com/keybase/go-framed-msgpack-rpc"
	context "golang.org/x/net/context"
)

type CreateGregorSuperUserSessionTokenArg struct {
}

type AuthInternalInterface interface {
	CreateGregorSuperUserSessionToken(context.Context) (SessionToken, error)
}

func AuthInternalProtocol(i AuthInternalInterface) rpc.Protocol {
	return rpc.Protocol{
		Name: "gregor.1.authInternal",
		Methods: map[string]rpc.ServeHandlerDescription{
			"createGregorSuperUserSessionToken": {
				MakeArg: func() interface{} {
					ret := make([]CreateGregorSuperUserSessionTokenArg, 1)
					return &ret
				},
				Handler: func(ctx context.Context, args interface{}) (ret interface{}, err error) {
					ret, err = i.CreateGregorSuperUserSessionToken(ctx)
					return
				},
				MethodType: rpc.MethodCall,
			},
		},
	}
}

type AuthInternalClient struct {
	Cli rpc.GenericClient
}

func (c AuthInternalClient) CreateGregorSuperUserSessionToken(ctx context.Context) (res SessionToken, err error) {
	err = c.Cli.Call(ctx, "gregor.1.authInternal.createGregorSuperUserSessionToken", []interface{}{CreateGregorSuperUserSessionTokenArg{}}, &res)
	return
}
