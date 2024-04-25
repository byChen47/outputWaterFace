    IOdictionary waveProperties
    (
        IOobject
        (
            "waveProperties",
            "constant",
            mesh,
            IOobject::MUST_READ,
            IOobject::NO_WRITE
        )
    );

    dimensionedScalar theta0
    (
        "theta0",
        dimensionSet(0,0,-1,0,0,0,0),
        waveProperties
    );

    dimensionedScalar theta1
    (
        "dampCoffe",
        dimensionSet(0,0,-1,0,0,0,0),
        waveProperties
    );  

    dimensionedScalar x1 = max(mesh.Cf().component(vector::X))
                        - min(mesh.Cf().component(vector::X));

    dimensionedScalar x0
    (
        "dampZoneStarPoint",
        dimensionSet(0,1,0,0,0,0,0),
        waveProperties
    );

    volScalarField thetaField
    (
        "thetaField",
        min(max(theta1 * (mesh.C().component(vector::X)-x0)/(x1 - x0),theta0),theta1)
    );

    MRF.correctBoundaryVelocity(U);

    fvVectorMatrix UEqn
    (
        fvm::ddt(rho, U) + fvm::div(rhoPhi, U)
      + MRF.DDt(rho, U)
      + turbulence->divDevRhoReff(rho, U)
      + thetaField * U * rho
     ==
        fvOptions(rho, U)
    );

    UEqn.relax();

    fvOptions.constrain(UEqn);

    if (pimple.momentumPredictor())
    {
        solve
        (
            UEqn
         ==
            fvc::reconstruct
            (
                (
                    mixture.surfaceTensionForce()
                  - ghf*fvc::snGrad(rho)
                  - fvc::snGrad(p_rgh)
                ) * mesh.magSf()
            )
        );

        fvOptions.correct(U);
    }
