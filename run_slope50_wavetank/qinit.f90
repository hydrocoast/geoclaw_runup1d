subroutine qinit(meqn,mbc,mx,xlower,dx,q,maux,aux)

    ! Set initial conditions for the q array.

    use geoclaw_module, only: sea_level
    use grid_module, only: xcell

    ! uncomment if any of these needed...
    !use geoclaw_module, only: dry_tolerance, grav

    implicit none

    integer, intent(in) :: meqn,mbc,mx,maux
    real(kind=8), intent(in) :: xlower,dx
    real(kind=8), intent(in) :: aux(maux,1-mbc:mx+mbc)
    real(kind=8), intent(inout) :: q(meqn,1-mbc:mx+mbc)

    !locals
    integer :: i

    real(kind=8) :: h0, eta, eta_star, x0, ampl, u, u_star, c, gamma_w, a

    x0 = 5000.0d0
    a = 1.0d-2  ! dimensionless amplitude
    h0 = 100.0d0  ! depth for scaling
    ampl = a*h0  ! amplitude
    gamma_w = sqrt(3.d0*ampl / (4.d0*h0))
    c = sqrt(1.d0 + a)

    do i=1,mx
        eta = ampl / cosh(gamma_w*(xcell(i) - x0)/h0)**2
        eta_star = eta/h0
        u_star = c * eta_star/(1.d0 + eta_star)
        u = u_star * sqrt(9.81d0*h0)
        q(1,i) = max(sea_level, eta - aux(1,i))
        q(2,i) = q(1,i)*u
   enddo


end subroutine qinit
